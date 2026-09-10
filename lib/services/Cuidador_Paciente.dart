import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/services/usuario_service.dart';
import 'package:rutina_app/utils/global.dart';

class CuidadorPaciente {
final UsuarioService usuarioService = UsuarioService();

Future<Map<String, dynamic>?> buscarPacientePorEmail(String email) async {
try {
final response = await supabase.rpc(
'buscar_paciente_por_email',
params: {'email_buscado': email},
);

if (response == null || (response as List).isEmpty) {
return null;
}

return response.first as Map<String, dynamic>;
} catch (e) {
throw Exception('Error al buscar paciente por correo: $e');
}
}

Future<void> asignarPaciente(
String pacienteId,
String cuidadorId,
) async {
try {
await supabase.from('cuidador_paciente').insert({
'cuidador_id': cuidadorId,
'paciente_id': pacienteId,
});
} catch (e) {
throw Exception('No se pudo asignar Paciente: $e');
}
}

Future<List<Paciente>> obetenerPaciendeDeCuidador(
String cuidadorId,
) async {
try {
final response = await supabase
    .from('cuidador_paciente')
    .select('''
            paciente_id,
            pacientes(
              *,
              usuarios(*)
            )
          ''')
    .eq('cuidador_id', cuidadorId);

final List<Paciente> pacientes = [];

for (final registro in response) {
final pacienteData = registro['pacientes'];

if (pacienteData == null) {
continue;
}

if (pacienteData is Map<String, dynamic>) {
pacientes.add(
Paciente.fromMap(pacienteData),
);
}
}

return pacientes;
} catch (e) {
throw Exception(
'Error al obtener pacientes del cuidador: $e',
);
}
}

Future<void> eliminarPaciente(
String cuidadorId,
String pacienteId,
) async {
try {
await supabase
    .from('cuidador_paciente')
    .delete()
    .eq('cuidador_id', cuidadorId)
    .eq('paciente_id', pacienteId);
} catch (e) {
throw Exception(
'Error al quitar paciente del cuidador: $e',
);
}
}
}
