import 'package:rutina_app/models/usuario.dart';
import 'package:rutina_app/utils/global.dart';

class UsuarioService {

  // El id que llega en 'usuario' debe ser el mismo uid que entrega
  // Supabase Auth al registrarse (auth.uid()), así la fila en 'usuarios'
  // queda vinculada 1 a 1 con el usuario autenticado.
  Future<String> crearUsuario(Usuario usuario) async {
    try {
      final datos = usuario.toMap();
      datos['id'] = usuario.id; // forzamos el id, no dejamos que Supabase lo genere

      final response = await supabase
          .from('usuarios')
          .insert(datos)
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
    try {
      await supabase
          .from('usuarios')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar el usuario: $e');
    }
  }

}