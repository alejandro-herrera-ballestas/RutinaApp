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

  Future<Map<String, dynamic>?> obtenerUsuario(String id) async {
    try {
      final response = await supabase
          .from('usuarios')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  Future<void> actualizarUsuario(Usuario usuario) async {
    try {
       await supabase
          .from('usuarios')
          .update(usuario.toMap())
          .eq('id', usuario.id);
    } catch(e)  {
      throw Exception('Error al actualizar el usuario: $e');
    }
  }

  Future<void> eliminarUsuario(String id) async {
    throw UnimplementedError();
  }

}