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
    // Primero obtenemos únicamente las relaciones.
    final relaciones = await supabase
        .from('cuidador_paciente')
        .select('paciente_id')
        .eq('cuidador_id', cuidadorId);

    final List<Paciente> pacientes = [];

    for (final relacion in relaciones) {
      final pacienteId = relacion['paciente_id'];

      if (pacienteId == null) {
        continue;
      }

      try {
        final paciente = await supabase
            .from('pacientes')
            .select('*, usuarios(*)')
            .eq('id', pacienteId)
            .maybeSingle();

        if (paciente != null) {
          pacientes.add(
            Paciente.fromMap(paciente),
          );
        }
      } catch (e) {
        print(
          'No se pudo obtener el paciente $pacienteId: $e',
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
