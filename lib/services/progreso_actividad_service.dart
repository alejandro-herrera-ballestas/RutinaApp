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

  // Guarda el progreso de UNA actividad en UN día con una sola llamada
  // (upsert). Ya existe un índice único (actividad_id, fecha), así que
  // no hace falta consultar antes: si existe lo actualiza, si no lo crea.
  Future<void> marcarProgreso(
    String actividadId,
    DateTime fecha,
    bool completada,
  ) async {
    try {
      final fechaStr = fecha.toIso8601String().split('T')[0];

      await supabase.from('progreso_actividad').upsert(
        {
          'actividad_id': actividadId,
          'fecha': fechaStr,
          'completada': completada,
          // toUtc() es importante: sin zona horaria la hora se guardaría
          // corrida (en Colombia, 5 horas).
          'hora_completada':
              completada ? DateTime.now().toUtc().toIso8601String() : null,
        },
        onConflict: 'actividad_id,fecha',
      );
    } catch (e) {
      throw Exception('Error al actualizar el progreso: $e');
    }
  }
}
