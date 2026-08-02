import 'package:rutina_app/models/cuidador.dart';
import 'package:rutina_app/services/usuario_service.dart';

class CuidadorService {

  final UsuarioService usuarioService = UsuarioService();

  Future<void> crearCuidador(Cuidador cuidador) async{
    throw UnimplementedError();
  }

  Future<Cuidador> obtenerCuidador(String id) async{
    throw UnimplementedError();
  }

  Future<Cuidador> obetenerTodosCuidadores()  async{
    throw UnimplementedError();
  }

  Future<void> eliminarCuidador() async{
    throw UnimplementedError();
  }
}