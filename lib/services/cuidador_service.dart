import 'package:rutina_app/models/cuidador.dart';
import 'package:rutina_app/services/usuario_service.dart';
import 'package:rutina_app/utils/global.dart';

class CuidadorService {

  final UsuarioService usuarioService = UsuarioService();

  Future<void> crearCuidador(Cuidador cuidador) async{
    try {
      final String idUsuario = await usuarioService.crearUsuario(cuidador);

      await supabase
          .from('cuidador')
          .insert({
        'usuario_id': idUsuario,
      });

    } catch (e) {
      throw Exception("Error al crear cuidador: $e");
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
      throw Exception('Error al obtener paciente: $e');
    }
  }

  Future<List<Cuidador>> obetenerTodosCuidadores()  async{
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
      throw Exception('Error al eliminar pacientes: $e');
    }
  }
}