import 'package:rutina_app/models/cuidador.dart';
import 'package:rutina_app/services/usuario_service.dart';

class CuidadorService {

  final UsuarioService usuarioService = UsuarioService();

  Future<void> crearCuidador(Cuidador cuidador) {
    throw UnimplementedError();
  }

  Future<Cuidador> obtenerCuidador(String id) {
    throw UnimplementedError();
  }

  Future<Cuidador> obetenerTodosCuidadores()  {
    throw UnimplementedError();
  }

  Future<void> eliminarCuidador() {
    throw UnimplementedError();
  }
}