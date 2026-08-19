import 'package:flutter/material.dart';
import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/utils/global.dart';

class ActividadService {
  final List<Actividad> _actividades = [];

  // ============================================================
  // SUPABASE
  // ============================================================

  // Crear una actividad para un paciente
  Future<void> crearActividad(
      Actividad actividad,
      String pacienteId,
      ) async {
    try {
      await supabase
          .from('actividades')
          .insert({
        'paciente_id': pacienteId,
        ...actividad.toMap(),
      });
    } catch (e) {
      throw Exception('Error al crear actividad: $e');
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

  // Obtener todas las actividades de un paciente
  Future<List<Actividad>> obtenerActividadesPaciente(
      String pacienteId,
      ) async {
    try {
      final response = await supabase
          .from('actividades')
          .select()
          .eq('paciente_id', pacienteId);

      return response
          .map((actividad) => Actividad.fromMap(actividad))
          .toList();
    } catch (e) {
      throw Exception(
        'Error al obtener actividades del paciente: $e',
      );
    }
  }

  // Actualizar una actividad en Supabase
  Future<void> actualizarActividad(
      Actividad actividad,
      ) async {
    try {
      await supabase
          .from('actividades')
          .update(actividad.toMap())
          .eq('id', actividad.id);
    } catch (e) {
      throw Exception(
        'Error al actualizar actividad: $e',
      );
    }
  }

  // Eliminar una actividad de Supabase
  Future<void> eliminarActividadSupabase(String id) async {
    try {
      await supabase
          .from('actividades')
          .delete()
          .eq('id', id);
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