import 'package:rutina_app/models/progreso_actividad.dart';
import 'package:rutina_app/utils/global.dart';

class ProgresoActividadService {

  Future<Map<String, ProgresoActividad>> obtenerProgresoDelDia(
    List<String> actividadIds,
    DateTime fecha,
  ) async {
    if (actividadIds.isEmpty) return {};

    try {
      final fechaStr = fecha.toIso8601String().split('T')[0];

      final response = await supabase
          .from('progreso_actividad')
          .select()
          .inFilter('actividad_id', actividadIds)
          .eq('fecha', fechaStr);

      final Map<String, ProgresoActividad> progresoPorActividad = {};
      for (final fila in response) {
        final progreso = ProgresoActividad.fromMap(fila);
        progresoPorActividad[progreso.actividadId] = progreso;
      }
      return progresoPorActividad;
    } catch (e) {
      throw Exception('Error al obtener el progreso del día: $e');
    }
  }

  Future<void> marcarProgreso(
    String actividadId,
    DateTime fecha,
    bool completada,
  ) async {
    try {
      final fechaStr = fecha.toIso8601String().split('T')[0];

      final existente = await supabase
          .from('progreso_actividad')
          .select('id')
          .eq('actividad_id', actividadId)
          .eq('fecha', fechaStr)
          .maybeSingle();

      final datos = {
        'actividad_id': actividadId,
        'fecha': fechaStr,
        'completada': completada,
        'hora_completada': completada ? DateTime.now().toIso8601String() : null,
      };

      if (existente == null) {
        await supabase.from('progreso_actividad').insert(datos);
      } else {
        await supabase
            .from('progreso_actividad')
            .update(datos)
            .eq('id', existente['id']);
      }
    } catch (e) {
      throw Exception('Error al actualizar el progreso: $e');
    }
  }
}
