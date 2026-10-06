import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/utils/global.dart';

// Notificaciones LOCALES: se programan en el celular de quien usa la app.
// - Si inicia sesión un paciente: avisos de sus actividades.
// - Si inicia sesión un cuidador: avisos de las actividades de TODOS sus
//   pacientes (con el nombre del paciente en el título).
//
// Cada actividad programa un aviso semanal por cada día marcado.
// Se vuelve a sincronizar al iniciar sesión y cada vez que se crea,
// edita o elimina una actividad, o se vincula/desvincula alguien.
//
// Escrito para flutter_local_notifications 22.x (parámetros con nombre).
class NotificationService {
  // Cuántos minutos ANTES de la hora de inicio avisar (0 = justo a la hora).
  static const int minutosAntes = 0;

  static const NotificationDetails _detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      'rutina_actividades',
      'Actividades de la rutina',
      channelDescription: 'Avisos de las actividades programadas',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _listo = false;
  bool _sincronizando = false;
  bool _pendiente = false;

  // Solo Android e iOS programan avisos. En web/Linux/Windows no hace nada
  // (así puedes seguir probando la app en escritorio sin que falle).
  bool get _plataformaSoportada {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  // Se llama una vez en main().
  Future<void> init() async {
    if (_listo || !_plataformaSoportada) return;

    tzdata.initializeTimeZones();

    // Zona horaria del celular. flutter_timezone devuelve un String en
    // versiones viejas y un objeto con .identifier en las nuevas, por eso
    // se usa dynamic. Si falla, se usa la de Colombia.
    try {
      final dynamic info = await FlutterTimezone.getLocalTimezone();
      final String nombre = info is String ? info : info.identifier as String;
      tz.setLocalLocation(tz.getLocation(nombre));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('America/Bogota'));
    }

    const configuracion = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: configuracion);
    _listo = true;
  }

  // Pide permiso para mostrar avisos (Android 13+ / iOS) y, en Android, el
  // permiso de alarmas exactas para que suenen puntuales.
  Future<bool> pedirPermisos() async {
    if (!_listo) return false;

    bool concedido = true;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      concedido = await android.requestNotificationsPermission() ?? false;

      final exactas = await android.canScheduleExactNotifications() ?? false;
      if (!exactas) {
        await android.requestExactAlarmsPermission();
      }
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      concedido = await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return concedido;
  }

  // Pide permisos y programa todo. Se llama después de iniciar sesión.
  Future<void> activarParaSesion() async {
    await pedirPermisos();
    await sincronizar();
  }

  Future<void> cancelarTodas() async {
    if (!_listo) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('No se pudieron cancelar los avisos: $e');
    }
  }

  // Borra todos los avisos y los vuelve a programar según lo que hay en
  // Supabase. Si se llama mientras ya está sincronizando, espera y repite
  // una vez más al terminar (para no perder el último cambio).
  Future<void> sincronizar() async {
    if (!_listo) return;

    if (_sincronizando) {
      _pendiente = true;
      return;
    }

    _sincronizando = true;
    try {
      do {
        _pendiente = false;
        await _sincronizarUnaVez();
      } while (_pendiente);
    } catch (e) {
      debugPrint('Error al sincronizar los avisos: $e');
    } finally {
      _sincronizando = false;
    }
  }

  Future<void> _sincronizarUnaVez() async {
    if (supabase.auth.currentUser == null) {
      await _plugin.cancelAll();
      return;
    }

    final bool esCuidador = authService.cuidadorActual != null;

    final List<Paciente> pacientes = [];
    if (esCuidador) {
      pacientes.addAll(authService.pacientesDelCuidador);
    } else if (authService.pacienteActual != null) {
      pacientes.add(authService.pacienteActual!);
    }

    // Primero se leen TODAS las actividades; si la lectura falla, los
    // avisos que ya estaban programados se quedan como están.
    final List<Actividad> actividades = [];
    final List<String?> nombresPaciente = [];

    for (final paciente in pacientes) {
      final delPaciente =
          await actividadService.obtenerActividadesPaciente(paciente.pacienteId);

      for (final actividad in delPaciente) {
        actividades.add(actividad);
        // El nombre del paciente solo se muestra si es un cuidador
        nombresPaciente.add(esCuidador ? paciente.nombre : null);
      }
    }

    await _plugin.cancelAll();

    final bool exactas = await _puedeProgramarExactas();

    for (int i = 0; i < actividades.length; i++) {
      await _programarActividad(actividades[i], nombresPaciente[i], exactas);
    }
  }

  Future<bool> _puedeProgramarExactas() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    return await android.canScheduleExactNotifications() ?? false;
  }

  // Un aviso semanal por cada día de la semana marcado en la actividad.
  Future<void> _programarActividad(
    Actividad actividad,
    String? nombrePaciente,
    bool exactas,
  ) async {
    final String titulo = nombrePaciente == null
        ? actividad.nombre
        : '${actividad.nombre} · $nombrePaciente';

    final String cuerpo = actividad.descripcion.trim().isNotEmpty
        ? actividad.descripcion
        : 'Es hora de empezar (${actividad.duracion.inMinutes} min)';

    for (final dia in actividad.diasSemana) {
      await _plugin.zonedSchedule(
        id: _idNotificacion(actividad.id, dia),
        title: titulo,
        body: cuerpo,
        scheduledDate: _proximoAviso(dia, actividad.hora),
        notificationDetails: _detalles,
        androidScheduleMode: exactas
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        // Se repite cada semana el mismo día de la semana y a la misma hora
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: actividad.id,
      );
    }
  }

  // Próxima fecha futura en que cae ese día de la semana (1 = lunes ...
  // 7 = domingo) a esa hora, menos los minutos de anticipación.
  tz.TZDateTime _proximoAviso(int diaSemana, TimeOfDay hora) {
    final ahora = tz.TZDateTime.now(tz.local);

    for (int i = 0; i <= 8; i++) {
      final candidata = tz.TZDateTime(
        tz.local,
        ahora.year,
        ahora.month,
        ahora.day + i,
        hora.hour,
        hora.minute,
      );

      if (candidata.weekday != diaSemana) continue;

      final aviso = candidata.subtract(const Duration(minutes: minutosAntes));
      if (aviso.isAfter(ahora)) {
        return aviso;
      }
    }

    // No debería pasar, pero por seguridad: mañana a esa hora
    return tz.TZDateTime(
      tz.local,
      ahora.year,
      ahora.month,
      ahora.day + 1,
      hora.hour,
      hora.minute,
    );
  }

  // Cada aviso necesita un id entero único y que no cambie entre
  // ejecuciones (así se puede cancelar luego). Se calcula con un hash
  // fijo (FNV-1a) del id de la actividad + el día de la semana (1..7).
  int _idNotificacion(String actividadId, int diaSemana) {
    int hash = 0x811c9dc5;
    for (final unidad in actividadId.codeUnits) {
      hash ^= unidad;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return ((hash & 0xFFFFFF) << 3) | diaSemana;
  }
}
