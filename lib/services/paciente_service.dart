
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/services/usuario_service.dart';

class PacienteService {

  final UsuarioService usuarioService = UsuarioService();

  Future<void> crearPaciente(Paciente paciente) async{
    throw UnimplementedError();
  }

  Future<Paciente> obtenerPaciente(String id) async{
    throw UnimplementedError();
  }

  Future<List<Paciente>> obtenerTodosPacientes()  async{
    throw UnimplementedError();
  }

  Future<void> eliminarPaciente() async{
    throw UnimplementedError();
  }
}