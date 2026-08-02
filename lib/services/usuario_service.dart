import 'package:rutina_app/models/usuario.dart';
import 'package:rutina_app/utils/global.dart';

class UsuarioService {

  Future<String> crearUsuario(Usuario usuario) async {
    try {
      final response = await supabase
          .from('usuarios')
          .insert(usuario.toMap())
          .select()
          .single();

      return response['id'];
    } catch(e)  {
      throw Exception("Error al crear el usuario: $e");
    }
  }

  Future<Usuario?> obtenerUsuario(String id) async {
    throw UnimplementedError();
  }

  Future<void> actualizarUsuario(Usuario usuario) async {
    throw UnimplementedError();
  }

  Future<void> eliminarUsuario(String id) async {
    throw UnimplementedError();
  }

}