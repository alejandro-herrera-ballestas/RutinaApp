import 'package:rutina_app/models/cuidador.dart';
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/models/horario.dart';
import 'package:rutina_app/models/usuario.dart';
import 'package:rutina_app/services/cuidador_service.dart';
import 'package:rutina_app/services/paciente_service.dart';
import 'package:rutina_app/utils/global.dart';

// Rol elegido al registrarse. Define si se crea un Cuidador o un Paciente.
enum RolUsuario { cuidador, paciente }

class AuthService {

  final CuidadorService cuidadorService = CuidadorService();
  final PacienteService pacienteService = PacienteService();

  Cuidador? _cuidadorActual;
  Paciente? _pacienteActual;

  // El resto de la app (perfil_screen, etc.) sigue pudiendo usar
  // authService.usuarioActual sin importar si es Cuidador o Paciente,
  // porque ambos extienden de Usuario.
  Usuario? get usuarioActual => _cuidadorActual ?? _pacienteActual;

  Cuidador? get cuidadorActual => _cuidadorActual;
  Paciente? get pacienteActual => _pacienteActual;

  // Registra una cuenta nueva en Supabase Auth y, con el uid que devuelve,
  // crea la fila correspondiente en 'usuarios' + 'cuidadores' o 'pacientes'.
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

    try {
      if (rol == RolUsuario.cuidador) {
        final cuidador = Cuidador(
          id: authUser.id,
          nombre: nombre,
          fechaNacimiento: fechaNacimiento,
          fotoPerfil: '',
          telefono: telefono ?? '',
          pacientes: [],
        );
        await cuidadorService.crearCuidador(cuidador);
        _cuidadorActual = cuidador;
        _pacienteActual = null;
      } else {
        final paciente = Paciente(
          id: authUser.id,
          nombre: nombre,
          fechaNacimiento: fechaNacimiento,
          fotoPerfil: '',
          horario: Horario(bloques: []),
        );
        await pacienteService.crearPaciente(paciente);
        _pacienteActual = paciente;
        _cuidadorActual = null;
      }
    } catch (e) {
      // si falla la creación de la fila en usuarios/cuidadores/pacientes,
      // no dejamos una cuenta de Auth huérfana sin datos asociados.
      await supabase.auth.signOut();
      rethrow;
    }
  }

  // Inicia sesión con Supabase Auth y carga el Cuidador o Paciente
  // correspondiente. Devuelve false si las credenciales son incorrectas.
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
        return true;
      }

      final paciente = await pacienteService.obtenerPacientePorUsuarioId(authUser.id);
      if (paciente != null) {
        _pacienteActual = paciente;
        _cuidadorActual = null;
        return true;
      }

      // el usuario existe en Auth pero no tiene fila en cuidadores/pacientes
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    await supabase.auth.signOut();
    _cuidadorActual = null;
    _pacienteActual = null;
  }
}