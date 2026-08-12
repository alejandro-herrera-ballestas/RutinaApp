
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

  Future<List<Paciente>> obtenerTodosPacientes()  async{
    throw UnimplementedError();
  }

  Future<void> eliminarPaciente(String id) async{
    throw UnimplementedError();
  }
}