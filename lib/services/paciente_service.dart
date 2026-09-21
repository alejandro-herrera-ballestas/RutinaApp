import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/paciente.dart';

class PacienteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Crear un nuevo paciente en la base de datos (Usado en registrarUsuario)
  Future<void> crearPaciente(Paciente paciente) async {
    try {
      await _supabase.from('pacientes').insert({
        'id': paciente.id,
        'nombre': paciente.nombre,
        'email': paciente.email,
        'fecha_nacimiento': paciente.fechaNacimiento.toIso8601String(),
        'foto_perfil': paciente.fotoPerfil,
      });
    } catch (e) {
      print('Error al crear paciente: $e');
      rethrow;
    }
  }

  // 2. Obtener paciente por su UUID de usuario (Usado en login/registro)
  Future<Paciente?> obtenerPacientePorUsuarioId(String idUsuario) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select('*, usuarios(*)')
          .eq('usuario_id', idUsuario)
          .maybeSingle();

      if (response == null) return null;

      return Paciente.fromMap(response);
    } catch (e) {
      print('Error al obtener paciente por ID de usuario: $e');
      return null;
    }
  }

  // 3. Obtener pacientes vinculados a un cuidador mediante JOIN
  Future<List<Paciente>> obtenerPacientesDeCuidador(String idCuidador) async {
    try {
      final response = await _supabase
          .from('cuidador_paciente')
          .select('paciente_id, pacientes(*, usuarios(*))')
          .eq('cuidador_id', idCuidador);

      final List<Paciente> pacientes = [];

      for (var item in (response as List)) {
        if (item['pacientes'] != null) {
          pacientes.add(Paciente.fromMap(item['pacientes'] as Map<String, dynamic>));
        }
      }

      return pacientes;
    } catch (e) {
      print('Error al obtener pacientes del cuidador: $e');
      return [];
    }
  }

  // 4. Obtener un paciente específico por su ID
  Future<Paciente?> obtenerPacientePorId(String idPaciente) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select('*, usuarios(*)')
          .eq('id', idPaciente)
          .maybeSingle();

      if (response == null) return null;

      return Paciente.fromMap(response);
    } catch (e) {
      print('Error al obtener paciente por ID: $e');
      return null;
    }
  }
}