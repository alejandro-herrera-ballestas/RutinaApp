import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/models/cuidador.dart';
import 'package:rutina_app/services/usuario_service.dart';
import 'package:rutina_app/utils/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CuidadorPaciente {
  final UsuarioService usuarioService = UsuarioService();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> buscarPacientePorEmail(String email) async {
    try {
      final response = await supabase.rpc(
        'buscar_paciente_por_email',
        params: {'email_buscado': email},
      );

      if (response == null || (response as List).isEmpty) {
        return null;
      }

      return response.first as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error al buscar paciente por correo: $e');
    }
  }

  Future<void> asignarPaciente(
      String pacienteId,
      String cuidadorId,
      ) async {
    try {
      await supabase.from('cuidador_paciente').upsert({
        'cuidador_id': cuidadorId,
        'paciente_id': pacienteId,
      }, onConflict: 'cuidador_id,paciente_id', ignoreDuplicates: true);
    } catch (e) {
      throw Exception('No se pudo asignar Paciente: $e');
    }
  }

  Future<List<Paciente>> obtenerPacientesDeCuidador(
      String cuidadorId,
      ) async {
    try {
      final relaciones = await supabase
          .from('cuidador_paciente')
          .select('paciente_id')
          .eq('cuidador_id', cuidadorId);

      final List<Paciente> pacientes = [];

      for (final relacion in relaciones) {
        final pacienteId = relacion['paciente_id'];

        if (pacienteId == null) {
          continue;
        }

        final paciente = await supabase
            .from('pacientes')
            .select('*, usuarios(*)')
            .eq('id', pacienteId)
            .maybeSingle();

        if (paciente != null) {
          pacientes.add(
            Paciente.fromMap(paciente),
          );
        }
      }

      return pacientes;
    } catch (e) {
      throw Exception(
        'Error al obtener pacientes del cuidador: $e',
      );
    }
  }

  Future<void> eliminarPaciente(
      String cuidadorId,
      String pacienteId,
      ) async {
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

  Future<List<Cuidador>> obtenerCuidadoresDePaciente(
      String pacienteId,
      ) async {
    try {
      final relaciones = await supabase
          .from('cuidador_paciente')
          .select('cuidador_id')
          .eq('paciente_id', pacienteId);

      final List<Cuidador> cuidadores = [];

      for (final relacion in relaciones) {
        final cuidadorId = relacion['cuidador_id'];

        if (cuidadorId == null) {
          continue;
        }

        final cuidadorMap = await supabase
            .from('cuidadores')
            .select('*, usuarios(*)')
            .eq('id', cuidadorId)
            .maybeSingle();

        if (cuidadorMap != null) {
          cuidadores.add(
            Cuidador.fromMap(cuidadorMap),
          );
        }
      }

      return cuidadores;
    } catch (e) {
      throw Exception(
        'Error al obtener cuidadores del paciente: $e',
      );
    }
  }

  // 1. Vincular un paciente
  Future<void> vincularPaciente(String idCuidador, String idPaciente) async {
    await _supabase.from('cuidador_paciente').insert({
      'cuidador_id': idCuidador,
      'paciente_id': idPaciente,
    });
  }

  // 2. Obtener la lista de pacientes vinculados
  Future<List<Map<String, dynamic>>> obtenerPacientesVinculados(String idCuidador) async {
    final response = await _supabase
        .from('cuidador_paciente')
        .select('paciente_id, paciente:pacientes(*, usuarios(*))')
        .eq('cuidador_id', idCuidador);

    return List<Map<String, dynamic>>.from(response);
  }
}
