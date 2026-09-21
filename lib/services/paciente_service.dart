import 'package:supabase_flutter/supabase_flutter.dart';

class PacienteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene la lista completa de pacientes vinculados a un cuidador específico
  Future<List<Map<String, dynamic>>> obtenerPacientesDelCuidador(String idCuidador) async {
    try {
      // Hacemos el JOIN entre cuidador_paciente y paciente utilizando las claves correctas
      final response = await _supabase
          .from('cuidador_paciente')
          .select('paciente_id, paciente(*)')
          .eq('cuidador_id', idCuidador);

      final List<Map<String, dynamic>> listaPacientes = [];

      for (var item in (response as List)) {
        if (item['paciente'] != null) {
          listaPacientes.add(item['paciente'] as Map<String, dynamic>);
        }
      }

      return listaPacientes;
    } catch (e) {
      print('Error al obtener los pacientes del cuidador: $e');
      return [];
    }
  }

  /// Obtiene un paciente específico por su ID (UUID)
  Future<Map<String, dynamic>?> obtenerPacientePorId(String idPaciente) async {
    try {
      final response = await _supabase
          .from('paciente')
          .select()
          .eq('id', idPaciente)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error al obtener paciente por ID: $e');
      return null;
    }
  }
}