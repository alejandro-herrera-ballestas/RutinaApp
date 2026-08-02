
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/services/usuario_service.dart';

class PacienteService {

  final UsuarioService usuarioService = UsuarioService();

  Future<void> crearPaciente(Paciente paciente) {
    throw UnimplementedError();
  }

  Future<Paciente> obtenerPaciente(String id) {
    throw UnimplementedError();
  }
}