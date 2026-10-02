// ignore_for_file: file_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/models/cuidador.dart';
import 'package:rutina_app/utils/global.dart';

// Maneja el vínculo cuidador <-> paciente.
// Ahora el vínculo SOLO se crea con un código que genera el paciente
// (así el paciente acepta). Ya no se busca por correo.
class CuidadorPaciente {

  // Traduce los errores que lanzan las funciones de Supabase a mensajes claros
  Exception _traducirError(Object e, String mensajeBase) {
    if (e is PostgrestException) {
      if (e.message.contains('DEMASIADOS_INTENTOS')) {
        return Exception('Demasiados intentos fallidos. Espera unos minutos e inténtalo de nuevo.');
      }
      if (e.message.contains('SOLO_CUIDADOR')) {
        return Exception('Solo un cuidador puede usar un código de vinculación.');
      }
      if (e.message.contains('SOLO_PACIENTE')) {
        return Exception('Solo un paciente puede generar un código.');
      }
    }
    return Exception('$mensajeBase: $e');
  }

  // EL PACIENTE genera un código de 6 caracteres que dura 30 minutos.
  // Devuelve {'codigo': 'K7M2QX', 'expira_en': '2026-...'}
  Future<Map<String, dynamic>> generarCodigo() async {
    try {
      final respuesta = await supabase.rpc('generar_codigo_vinculo');

      final lista = respuesta as List;
      if (lista.isEmpty) {
        throw Exception('No se recibió ningún código.');
      }

      return Map<String, dynamic>.from(lista.first as Map);
    } catch (e) {
      throw _traducirError(e, 'No se pudo generar el código');
    }
  }

  // EL CUIDADOR escribe el código del paciente.
  // Devuelve {'paciente_id': ..., 'nombre': ...} si salió bien,
  // o null si el código es inválido, ya se usó o está vencido.
  Future<Map<String, dynamic>?> vincularConCodigo(String codigo) async {
    try {
      final respuesta = await supabase.rpc(
        'vincular_con_codigo',
        params: {'p_codigo': codigo.trim().toUpperCase()},
      );

      final lista = respuesta as List;
      if (lista.isEmpty) {
        return null;
      }

      return Map<String, dynamic>.from(lista.first as Map);
    } catch (e) {
      throw _traducirError(e, 'No se pudo vincular');
    }
  }

  // Pacientes de un cuidador, en UNA sola consulta (antes era una consulta
  // por cada paciente). Gracias a las políticas RLS nuevas el cuidador ya
  // puede leer los datos de sus pacientes vinculados.
  Future<List<Paciente>> obtenerPacientesDeCuidador(
    String cuidadorId,
  ) async {
    try {
      final relaciones = await supabase
          .from('cuidador_paciente')
          .select('pacientes(*, usuarios(*))')
          .eq('cuidador_id', cuidadorId);

      final List<Paciente> pacientes = [];

      for (final relacion in relaciones) {
        final pacienteMap = relacion['pacientes'];

        if (pacienteMap == null) {
          continue;
        }

        pacientes.add(
          Paciente.fromMap(Map<String, dynamic>.from(pacienteMap as Map)),
        );
      }

      return pacientes;
    } catch (e) {
      throw Exception(
        'Error al obtener pacientes del cuidador: $e',
      );
    }
  }

  // Cuidadores de un paciente, también en una sola consulta.
  Future<List<Cuidador>> obtenerCuidadoresDePaciente(
    String pacienteId,
  ) async {
    try {
      final relaciones = await supabase
          .from('cuidador_paciente')
          .select('cuidadores(*, usuarios(*))')
          .eq('paciente_id', pacienteId);

      final List<Cuidador> cuidadores = [];

      for (final relacion in relaciones) {
        final cuidadorMap = relacion['cuidadores'];

        if (cuidadorMap == null) {
          continue;
        }

        cuidadores.add(
          Cuidador.fromMap(Map<String, dynamic>.from(cuidadorMap as Map)),
        );
      }

      return cuidadores;
    } catch (e) {
      throw Exception(
        'Error al obtener cuidadores del paciente: $e',
      );
    }
  }

  // Quita el vínculo (sirve para "eliminar paciente" desde el cuidador y
  // "eliminar cuidador" desde el paciente). NO borra ninguna cuenta.
  // Con .select() sabemos cuántas filas se borraron: si fue 0 es que no
  // había vínculo o no hay permiso, y antes eso fallaba en silencio.
  Future<void> desvincular(
    String cuidadorId,
    String pacienteId,
  ) async {
    try {
      final borradas = await supabase
          .from('cuidador_paciente')
          .delete()
          .eq('cuidador_id', cuidadorId)
          .eq('paciente_id', pacienteId)
          .select();

      if (borradas.isEmpty) {
        throw Exception('No se encontró el vínculo para quitar.');
      }
    } catch (e) {
      throw Exception('Error al quitar el vínculo: $e');
    }
  }
}
