import 'package:rutina_app/models/cuidador.dart';
import 'package:rutina_app/services/usuario_service.dart';
import 'package:rutina_app/utils/global.dart';

class CuidadorService {

  final UsuarioService usuarioService = UsuarioService();

  Future<void> crearCuidador(Cuidador cuidador) async{
    try {
      final String idUsuario = await usuarioService.crearUsuario(cuidador);

      await supabase
          .from('cuidadores')
          .insert({
        'usuario_id': idUsuario,
        'telefono': cuidador.telefono,
      });

    } catch (e) {
      throw Exception("Error al crear cuidador: $e");
    }
  }

  // Busca el cuidador a partir del id del usuario (= uid de Supabase Auth).
  // Se usa justo después de iniciar sesión, para saber si la persona
  // autenticada es un cuidador.
  Future<Cuidador?> obtenerCuidadorPorUsuarioId(String usuarioId) async {
    try {
      final response = await supabase
          .from('cuidadores')
          .select('''
      *,
      usuarios(*)
    ''')
          .eq('usuario_id', usuarioId)
          .maybeSingle();

      if (response == null) return null;
      return Cuidador.fromMap(response);
    } catch (e) {
      throw Exception('Error al obtener cuidador por usuario: $e');
    }
  }

  Future<Cuidador> obtenerCuidador(String id) async{
    try {
      final response = await supabase
          .from('cuidadores')
          .select('''
      *,
      usuarios(*)
    ''')
          .eq('id', id)
          .single();

      return Cuidador.fromMap(response);

    } catch (e) {
      throw Exception('Error al obtener cuidador: $e');
    }
  }

  Future<List<Cuidador>> obtenerTodosCuidadores()  async{
    try {
      final response = await supabase
          .from('cuidadores')
          .select('''
          *,
          usuarios(*)
        ''');

      return response
          .map((cuidadores) => Cuidador.fromMap(cuidadores))
          .toList();

    } catch (e) {
      throw Exception('Error al obtener cuidadores: $e');
    }
  }

  Future<void> eliminarCuidador(String id) async{
    try {
      final cuidadores = await supabase
          .from('cuidadores')
          .select('usuario_id')
          .eq('id', id)
          .single();

      final String usuarioId = cuidadores['usuario_id'];
      await usuarioService.eliminarUsuario(usuarioId);
    } catch (e) {
      throw Exception('Error al eliminar cuidador: $e');
    }
  }
}