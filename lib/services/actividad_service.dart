import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/utils/global.dart';

class ActividadService {

  // === DATABASE======

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

  // Obtener una actividad por su ID
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

  // Actualizar una actividad
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

  // Eliminar una actividad
  Future<void> eliminarActividad(String id) async {
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

  // ====== Funcionamiento  ===========

  bool completarActividadLocal(Actividad actividad) {
    if (actividad.completada) {
      return false;
    }

    actividad.completar();
    return true;
  }

  bool reiniciarActividadLocal(Actividad actividad) {
    if (!actividad.completada) {
      return false;
    }

    actividad.reiniciar();
    return true;
  }
}