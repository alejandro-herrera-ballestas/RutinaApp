
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/services/usuario_service.dart';
import 'package:rutina_app/utils/global.dart';

class PacienteService {

  final UsuarioService usuarioService = UsuarioService();

  Future<void> crearPaciente(Paciente paciente) async {
    try {
      final String idUsuario = await usuarioService.crearUsuario(paciente);

      await supabase
          .from('pacientes')
          .insert({
        'usuario_id': idUsuario,
      });

    } catch (e) {
      throw Exception("Error al crear paciente: $e");
    }
  }

  Future<Paciente> obtenerPaciente(String id) async{
    try {
      final response = await supabase
          .from('pacientes')
          .select('''
      *,
      usuarios(*)
    ''')
          .eq('id', id)
          .single();

      return Paciente.fromMap(response);

    } catch (e) {
      throw Exception('Error al obtener paciente: $e');
    }
  }

  Future<List<Paciente>> obtenerTodosPacientes() async {
    try {
      final response = await supabase
          .from('pacientes')
          .select('''
          *,
          usuarios(*)
        ''');

      return response
          .map((paciente) => Paciente.fromMap(paciente))
          .toList();

    } catch (e) {
      throw Exception('Error al obtener pacientes: $e');
    }
  }

  Future<void> eliminarPaciente(String id) async{
    try {
      final paciente = await supabase
          .from('pacientes')
          .select('usuario_id')
          .eq('id', id)
          .single();

      final String usuarioId = paciente['usuario_id'];
      await usuarioService.eliminarUsuario(usuarioId);
    } catch (e) {
      throw Exception('Error al eliminar pacientes: $e');
    }
  }
}