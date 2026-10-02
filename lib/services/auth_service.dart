// ignore_for_file: avoid_print

import 'dart:async';

import 'package:rutina_app/models/cuidador.dart';
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/models/usuario.dart';
import 'package:rutina_app/services/cuidador_service.dart';
import 'package:rutina_app/services/paciente_service.dart';
import 'package:rutina_app/services/Cuidador_Paciente.dart';
import 'package:rutina_app/utils/global.dart';

enum RolUsuario { cuidador, paciente }

class AuthService {

  final CuidadorService cuidadorService = CuidadorService();
  final PacienteService pacienteService = PacienteService();
  final CuidadorPaciente cuidadorPacienteService = CuidadorPaciente();

  Cuidador? _cuidadorActual;
  Paciente? _pacienteActual;
  Usuario? get usuarioActual => _cuidadorActual ?? _pacienteActual;

  Cuidador? get cuidadorActual => _cuidadorActual;
  Paciente? get pacienteActual => _pacienteActual;

  // Todos los pacientes vinculados al cuidador logueado (vacío si es un Paciente).
  List<Paciente> pacientesDelCuidador = [];

  Paciente? pacienteSeleccionado;

  void seleccionarPaciente(Paciente paciente) {
    pacienteSeleccionado = paciente;
  }

  Future<void> recargarPacientesDelCuidador() async {
    if (_cuidadorActual == null) return;

    final String? idSeleccionado = pacienteSeleccionado?.pacienteId;

    pacientesDelCuidador = await cuidadorPacienteService
        .obtenerPacientesDeCuidador(_cuidadorActual!.cuidadorId);

    if (pacientesDelCuidador.isEmpty) {
      pacienteSeleccionado = null;
      return;
    }

    // Buscamos al paciente que estaba seleccionado dentro de la lista NUEVA.
    // Antes se dejaba el objeto viejo, y el Dropdown del selector fallaba
    // porque ya no era el mismo objeto que está en la lista recargada.
    Paciente? coincidencia;
    for (final paciente in pacientesDelCuidador) {
      if (paciente.pacienteId == idSeleccionado) {
        coincidencia = paciente;
        break;
      }
    }

    pacienteSeleccionado = coincidencia ?? pacientesDelCuidador.first;
  }

  // Registro en 3 pasos: 1) crear la cuenta en Auth, 2) crear el perfil con
  // la función 'registrar_perfil' (usuarios + pacientes/cuidadores en UNA
  // sola transacción), 3) cargar el perfil recién creado.
  Future<void> registrarUsuario({
    required String email,
    required String contrasena,
    required String nombre,
    required DateTime fechaNacimiento,
    required RolUsuario rol,
    String? telefono, // obligatorio solo si rol == RolUsuario.cuidador
  }) async {
    final authResponse = await supabase.auth.signUp(
      email: email,
      password: contrasena,
    );

    final authUser = authResponse.user;
    if (authUser == null) {
      throw Exception('No se pudo crear la cuenta.');
    }

    // Sin sesión no hay auth.uid() y las políticas RLS rechazan todo.
    // Pasa si "Confirm email" está activado en Supabase.
    if (authResponse.session == null) {
      throw Exception(
        'La cuenta se creó pero necesita confirmar el correo antes de continuar.',
      );
    }

    try {
      await supabase.rpc('registrar_perfil', params: {
        'p_rol': rol == RolUsuario.cuidador ? 'cuidador' : 'paciente',
        'p_nombre': nombre.trim(),
        'p_fecha_nacimiento': fechaNacimiento.toIso8601String().split('T')[0],
        'p_telefono': telefono,
      });

      if (rol == RolUsuario.cuidador) {
        _cuidadorActual = await cuidadorService.obtenerCuidadorPorUsuarioId(authUser.id);
        _pacienteActual = null;
        pacientesDelCuidador = [];
        pacienteSeleccionado = null;
      } else {
        _pacienteActual = await pacienteService.obtenerPacientePorUsuarioId(authUser.id);
        _cuidadorActual = null;
        pacienteSeleccionado = _pacienteActual;
      }

      unawaited(notificationService.activarParaSesion());
    } catch (e) {
      await supabase.auth.signOut();
      rethrow;
    }
  }

  Future<bool> iniciarSesion(String email, String contrasena) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: contrasena,
      );

      final authUser = response.user;
      if (authUser == null) return false;

      final cuidador = await cuidadorService.obtenerCuidadorPorUsuarioId(authUser.id);
      if (cuidador != null) {
        _cuidadorActual = cuidador;
        _pacienteActual = null;
        await recargarPacientesDelCuidador();
        unawaited(notificationService.activarParaSesion());
        return true;
      }

      final paciente = await pacienteService.obtenerPacientePorUsuarioId(authUser.id);
      if (paciente != null) {
        _pacienteActual = paciente;
        _cuidadorActual = null;
        pacienteSeleccionado = paciente; // un paciente siempre "ve" sus propias actividades
        unawaited(notificationService.activarParaSesion());
        return true;
      }

      // el usuario existe en Auth pero no tiene fila en cuidadores/pacientes
      return false;
    } catch (e) {
      print('ERROR LOGIN: $e');
      rethrow;
    }
  }

  Future<void> cerrarSesion() async {
    // Se cancelan los avisos para que el celular no suene con las
    // actividades de una sesión que ya se cerró.
    await notificationService.cancelarTodas();

    await supabase.auth.signOut();
    _cuidadorActual = null;
    _pacienteActual = null;
    pacientesDelCuidador = [];
    pacienteSeleccionado = null;
  }
}
