import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/services/progreso_actividad_service.dart';
import 'package:rutina_app/services/storage_service.dart';
import 'package:rutina_app/utils/global.dart';

// Error que lanza la base de datos cuando una actividad se cruza en horario
// con otra del mismo paciente (en alguno de los mismos días).
class SolapeActividadException implements Exception {
  final String conflicto; // nombre de la actividad con la que se cruza

  SolapeActividadException(this.conflicto);

  @override
  String toString() {
    return 'Esta actividad se cruza con "$conflicto". '
        'Cambia la hora, la duración o los días.';
  }
}

class ActividadService {
  final List<Actividad> _actividades = [];
  final ProgresoActividadService progresoService = ProgresoActividadService();

  // ============================================================
  // SUPABASE
  // ============================================================

  // Convierte el error de Postgres en uno entendible para la pantalla.
  // El código 23P01 lo lanza el trigger que bloquea los solapes.
  Exception _traducirError(Object e, String mensaje) {
    if (e is PostgrestException && e.code == '23P01') {
      final coincidencia = RegExp(r'"(.*)"').firstMatch(e.message);
      return SolapeActividadException(coincidencia?.group(1) ?? 'otra actividad');
    }
    return Exception('$mensaje: $e');
  }

  // Trae las actividades de un paciente YA combinadas con su progreso
  // del día indicado. Solo devuelve las que ocurren ese día de la semana.
  Future<List<Actividad>> obtenerActividadesConProgreso(
    String pacienteId,
    DateTime fecha,
  ) async {
    final todas = await obtenerActividadesPaciente(pacienteId);
    return filtrarDiaConProgreso(todas, fecha);
  }

  // A partir de la lista COMPLETA del paciente, deja solo las que se repiten
  // en el día de la semana de 'fecha' y les pone su progreso de ese día.
  // Sirve cuando la pantalla ya cargó todas las actividades y no quiere
  // pedirlas otra vez (Inicio y Calendario).
  Future<List<Actividad>> filtrarDiaConProgreso(
    List<Actividad> todas,
    DateTime fecha,
  ) async {
    final List<Actividad> delDia = [];
    for (final actividad in todas) {
      if (actividad.ocurreEn(fecha)) {
        delDia.add(actividad);
      }
    }

    final List<String> ids = [];
    for (final actividad in delDia) {
      ids.add(actividad.id);
    }

    final progresoPorActividad = await progresoService.obtenerProgresoDelDia(
      ids,
      fecha,
    );

    for (final actividad in delDia) {
      final progreso = progresoPorActividad[actividad.id];
      actividad.completada = progreso?.completada ?? false;
      actividad.fechaCompletada = progreso?.horaCompletada;
    }

    return delDia;
  }

  // Crear una actividad para un paciente. Si viene una imagen nueva, se
  // sube primero a Storage y la ruta queda guardada en la actividad.
  // Lanza SolapeActividadException si se cruza con otra actividad.
  Future<void> crearActividad(
    Actividad actividad,
    String pacienteId, {
    File? imagen,
  }) async {
    String? rutaSubida;

    try {
      if (imagen != null) {
        rutaSubida = await storageService.subirImagen(
          bucket: StorageService.bucketActividades,
          carpeta: pacienteId,
          nombreBase: const Uuid().v4(),
          archivo: imagen,
        );
        actividad.rutaIMG = rutaSubida;
      }

      await supabase.from('actividades').insert({
        'paciente_id': pacienteId,
        ...actividad.toMap(),
      });
    } catch (e) {
      // Si la actividad no se pudo guardar, no dejamos la imagen huérfana
      await storageService.borrar(StorageService.bucketActividades, rutaSubida);
      throw _traducirError(e, 'Error al crear actividad');
    }
  }

  // Obtener una actividad por su ID desde Supabase
  Future<Actividad> obtenerActividad(String id) async {
    try {
      final response = await supabase
          .from('actividades')
          .select()
          .eq('id', id)
          .single();

      return Actividad.fromMap(response);
    } catch (e) {
      throw Exception('Error al obtener actividad: $e');
    }
  }

  // Obtener TODAS las actividades de un paciente (de cualquier día),
  // ordenadas por hora. Las usa también el servicio de notificaciones.
  Future<List<Actividad>> obtenerActividadesPaciente(
    String pacienteId,
  ) async {
    try {
      final response = await supabase
          .from('actividades')
          .select()
          .eq('paciente_id', pacienteId)
          .order('hora_inicio', ascending: true);

      final List<Actividad> actividades = [];
      for (final fila in response) {
        actividades.add(Actividad.fromMap(fila));
      }
      return actividades;
    } catch (e) {
      throw Exception(
        'Error al obtener actividades del paciente: $e',
      );
    }
  }

  // Actualizar una actividad en Supabase. Si se elige una imagen nueva
  // se sube, y recién cuando la actividad se guarda bien se borra la vieja.
  // Lanza SolapeActividadException si se cruza con otra actividad.
  Future<void> actualizarActividad(
    Actividad actividad, {
    required String pacienteId,
    File? imagenNueva,
  }) async {
    final String rutaAnterior = actividad.rutaIMG;
    String? rutaSubida;

    try {
      if (imagenNueva != null) {
        rutaSubida = await storageService.subirImagen(
          bucket: StorageService.bucketActividades,
          carpeta: pacienteId,
          nombreBase: const Uuid().v4(),
          archivo: imagenNueva,
        );
        actividad.rutaIMG = rutaSubida;
      }

      await supabase
          .from('actividades')
          .update(actividad.toMap())
          .eq('id', actividad.id);

      if (rutaSubida != null) {
        await storageService.borrar(StorageService.bucketActividades, rutaAnterior);
      }
    } catch (e) {
      // Volvemos a dejar la ruta como estaba y borramos la imagen subida
      actividad.rutaIMG = rutaAnterior;
      await storageService.borrar(StorageService.bucketActividades, rutaSubida);
      throw _traducirError(e, 'Error al actualizar actividad');
    }
  }

  // Eliminar una actividad de Supabase (y su imagen de Storage)
  Future<void> eliminarActividadSupabase(String id, {String? rutaImagen}) async {
    try {
      await supabase
          .from('actividades')
          .delete()
          .eq('id', id);

      await storageService.borrar(StorageService.bucketActividades, rutaImagen);
    } catch (e) {
      throw Exception(
        'Error al eliminar actividad: $e',
      );
    }
  }

  // ============================================================
  // FUNCIONAMIENTO LOCAL ORIGINAL
  // ============================================================

  // Agregar una nueva actividad
  bool agregarActividad(Actividad actividad) {
    // Verificar que no exista una actividad con el mismo ID
    for (Actividad a in _actividades) {
      if (a.id == actividad.id) {
        return false;
      }
    }

    _actividades.add(actividad);
    return true;
  }

  // Obtener todas las actividades locales
  List<Actividad> obtenerActividades() {
    return List.from(_actividades);
  }

  // Buscar una actividad local por su ID
  Actividad? buscarActividad(String id) {
    for (Actividad a in _actividades) {
      if (a.id == id) {
        return a;
      }
    }

    return null;
  }

  // Editar una actividad local
  bool editarActividad(
    String id, {
    String? nombre,
    String? descripcion,
    String? rutaIMG,
    TimeOfDay? hora,
    Duration? duracion,
    List<int>? dias,
  }) {
    Actividad? actividad = buscarActividad(id);

    if (actividad == null) {
      return false;
    }

    actividad.editar(
      nuevoNombre: nombre,
      nuevaDescripcion: descripcion,
      nuevaRutaIMG: rutaIMG,
      nuevaHora: hora,
      nuevaDuracion: duracion,
      nuevosDias: dias,
    );

    return true;
  }

  // Eliminar una actividad local
  bool eliminarActividad(String id) {
    Actividad? actividad = buscarActividad(id);

    if (actividad == null) {
      return false;
    }

    _actividades.remove(actividad);
    return true;
  }

  // Reordenar actividades
  bool reordenarActividades(
    int oldIndex,
    int newIndex,
  ) {
    if (oldIndex < 0 ||
        oldIndex >= _actividades.length ||
        newIndex < 0 ||
        newIndex > _actividades.length) {
      return false;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    Actividad actividad = _actividades.removeAt(oldIndex);
    _actividades.insert(newIndex, actividad);

    return true;
  }

  // Marcar una actividad como completada
  bool completarActividad(String id) {
    Actividad? actividad = buscarActividad(id);

    if (actividad == null) {
      return false;
    }

    if (actividad.completada) {
      return false;
    }

    actividad.completar();
    return true;
  }

  // Reiniciar una actividad
  bool reiniciarActividad(String id) {
    Actividad? actividad = buscarActividad(id);

    if (actividad == null) {
      return false;
    }

    if (!actividad.completada) {
      return false;
    }

    actividad.reiniciar();
    return true;
  }

  // Cantidad de actividades
  int cantidadActividades() {
    return _actividades.length;
  }

  // Eliminar todas las actividades locales
  void limpiarActividades() {
    _actividades.clear();
  }

  // Contador de actividades completadas
  int actividadesCompletadas() {
    int contador = 0;

    for (Actividad actividad in _actividades) {
      if (actividad.completada) {
        contador++;
      }
    }

    return contador;
  }
}
