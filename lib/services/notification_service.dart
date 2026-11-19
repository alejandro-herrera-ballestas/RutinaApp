import 'package:rutina_app/screens/detalle_actividad_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay, MaterialPageRoute;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'dart:typed_data';

import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/utils/global.dart';

// notificaciones locales
// Se encarga de programar avisos para las actividades de la rutina
class NotificationService {
  // Cuántos minutos ANTES de la hora de inicio avisar (0 = justo a la hora).
  static const int minutosAntes = 0;

    static final NotificationDetails _detallesInicio = NotificationDetails(
    android: AndroidNotificationDetails(
      'rutina_alarma_inicio_v2',
      'Inicio de actividades',
      channelDescription: 'Alarma al empezar cada actividad',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
      sound: const RawResourceAndroidNotificationSound('alarma'),
      additionalFlags: Int32List.fromList(<int>[4]),
    ),
    iOS: const DarwinNotificationDetails(),
  );

  static final NotificationDetails _detallesFin = NotificationDetails(
    android: AndroidNotificationDetails(
      'rutina_alarma_fin_v2',
      'Fin de actividades',
      channelDescription: 'Alarma al terminar cada actividad',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
      sound: const RawResourceAndroidNotificationSound('alarma'),
      additionalFlags: Int32List.fromList(<int>[4]),
    ),
    iOS: const DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Id de la actividad de una alarma tocada antes de que la sesion estuviera lista
  String? _payloadPendiente;
  bool _listo = false;
  bool _sincronizando = false;
  bool _pendiente = false;

  // Solo Android e iOS programan avisos. En web/Linux/Windows no hace nada
  bool get _plataformaSoportada {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  // Se llama una vez en main()
  Future<void> init() async {
    if (_listo || !_plataformaSoportada) return;

    tzdata.initializeTimeZones();

    // Zona horaria del celular
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

        await _plugin.initialize( // Se llama al tocar un aviso
      settings: configuracion,
      onDidReceiveNotificationResponse: _alTocar,
    );

    // Si la app estaba cerrada y la abrio una alarma, guardamos su id
    final detallesInicio = await _plugin.getNotificationAppLaunchDetails();
    if (detallesInicio != null && detallesInicio.didNotificationLaunchApp) {
      _payloadPendiente = detallesInicio.notificationResponse?.payload;
    }

    _listo = true;
  }

  // Pide permiso para mostrar avisos 
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
            await android.requestFullScreenIntentPermission();
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

  // Borra todos los avisos y los vuelve a programar según lo que hay en la basd de datos
  Future<void> sincronizar() async {
    if (!_listo) return;

    if (_sincronizando) { // Si ya se está sincronizando, se marca que hay un cambio pendiente
      _pendiente = true;
      return;
    }
// Si no se está sincronizando, se hace la sincronización
    _sincronizando = true;
    try {
      do {
        _pendiente = false; // Se borra la marca de pendiente antes de sincronizar, para que si durante la sincronización se marca otra vez, quede pendiente para la siguiente iteración
        await _sincronizarUnaVez(); // Se hace la sincronización una vez
      } while (_pendiente); // Si durante la sincronización se marcó que hay un cambio pendiente, se vuelve a sincronizar
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

    // La sesion esta lista cuando ya se cargo el cuidador o el paciente
  bool get _sesionCargada {
    return supabase.auth.currentUser != null &&
        (authService.cuidadorActual != null ||
            authService.pacienteActual != null);
  }

  void _alTocar(NotificationResponse respuesta) {
    _abrirActividad(respuesta.payload);
  }

  // Lo llama el Splash cuando ya entro a la app
  Future<void> abrirPendiente() async {
    final id = _payloadPendiente;
    if (id == null) return;
    _payloadPendiente = null;
    await _abrirActividad(id);
  }

  Future<void> _abrirActividad(String? id) async {
    if (id == null || id.isEmpty) return;

    // Si todavia no hay sesion o pantalla, se deja guardado para despues
    if (!_sesionCargada || navigatorKey.currentState == null) {
      _payloadPendiente = id;
      return;
    }

    try {
      final actividad = await actividadService.obtenerActividad(id);
      final hoy = DateTime.now();

      // Le pone el progreso de hoy (completada o no)
      await actividadService.filtrarDiaConProgreso([actividad], hoy);

      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => DetalleActividadScreen(
            actividad: actividad,
            fecha: hoy,
          ),
        ),
      );
    } catch (e) {
      debugPrint('No se pudo abrir la actividad de la alarma: $e');
    }
  }

    // Un aviso de inicio y uno de fin por cada dia de la semana marcado
  Future<void> _programarActividad(
    Actividad actividad,
    String? nombrePaciente,
    bool exactas,
  ) async {
    final String titulo = nombrePaciente == null
        ? actividad.nombre
        : '${actividad.nombre} - $nombrePaciente';

    final String cuerpo = actividad.descripcion.trim().isNotEmpty
        ? actividad.descripcion
        : 'Es hora de empezar (${actividad.duracion.inMinutes} min)';

    final modo = exactas
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    // Hora de fin = hora de inicio + duracion
    final int inicioMin = actividad.hora.hour * 60 + actividad.hora.minute;
    final int finMin = inicioMin + actividad.duracion.inMinutes;
    final int diasExtra = finMin ~/ 1440; // 1 si pasa de medianoche
    final TimeOfDay horaFin = TimeOfDay(
      hour: (finMin % 1440) ~/ 60,
      minute: finMin % 60,
    );

    for (final dia in actividad.diasSemana) {
      // Aviso de inicio
      await _plugin.zonedSchedule(
        id: _idNotificacion(actividad.id, dia),
        title: titulo,
        body: cuerpo,
        scheduledDate: _proximoAviso(dia, actividad.hora),
        notificationDetails: _detallesInicio,
        androidScheduleMode: modo,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: actividad.id,
      );

      // Aviso de fin (si cruza medianoche cae el dia siguiente)
      final int diaFin = ((dia - 1 + diasExtra) % 7) + 1;
      await _plugin.zonedSchedule(
        id: _idNotificacion(actividad.id, dia, fin: true),
        title: 'Tiempo terminado',
        body: titulo,
        scheduledDate: _proximoAviso(diaFin, horaFin),
        notificationDetails: _detallesFin,
        androidScheduleMode: modo,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: actividad.id,
      );
    }
  }

  // Próxima fecha futura en que cae ese día de la semana 
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

  int _idNotificacion(String actividadId, int diaSemana, {bool fin = false}) {
  int hash = 0x811c9dc5;
  for (final unidad in actividadId.codeUnits) {
    hash ^= unidad;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  final extra = fin ? 8 : 0;
  return ((hash & 0xFFFFFF) << 4) | (diaSemana + extra);
}
}
