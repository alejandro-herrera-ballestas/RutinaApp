import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/services/usuario_service.dart';
import 'package:rutina_app/utils/global.dart';

class CuidadorPaciente {
  final UsuarioService usuarioService = UsuarioService();

  Future<void>asignarPaciente (String pacienteId, String cuidadorId) async {
    try {
      await supabase
          .from('cuidador_paciente')
          .insert({
        'cuidador_id': cuidadorId,
        'paciente_id': pacienteId,
          });
    }
    catch (e) {
      throw Exception('No se pudo asignar Paciente: $e');
    }
  }

  Future<List<Paciente>>obetenerPaciendeDeCuidador(String cuidadorId, ) async {
    try {
      final response = await supabase
          .from('cuidador_paciente')
          .select('''
        paciente_id,
        pacientes(
        *,
        usuarios(*)
      )
      ''')
          .eq('cuidador_id', cuidadorId);
      return response
          .map((registro) => Paciente.fromMap(registro['pacientes'])).toList();

    } catch (e) {
      throw Exception('Error al obetner pacientes del cuidador: $e');
    }
  }

  Future<void> eliminarPaciente(String cuidadorId, String pacienteId,) async {
    try {
      await supabase
          .from('cuidador_paciente')
          .delete()
          .eq('cuidador_id', cuidadorId)
          .eq('paciente_id', pacienteId);
    } catch (e) {
      throw Exception(
        'Error al quitar paciente del cuidador: $e',
      );
    }
  }
}