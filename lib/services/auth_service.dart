import 'package:rutina_app/models/cuidador.dart';
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/models/horario.dart';
import 'package:rutina_app/models/usuario.dart';
import 'package:rutina_app/services/cuidador_service.dart';
import 'package:rutina_app/services/paciente_service.dart';
import 'package:rutina_app/services/Cuidador_Paciente.dart';
import 'package:rutina_app/utils/global.dart';

// Rol elegido al registrarse. Define si se crea un Cuidador o un Paciente.
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

  // El paciente "activo" en pantalla: para un Paciente logueado es él mismo;
  // para un Cuidador es el que haya elegido en el selector. Home, Calendario
  // y AddActivity usan este valor, no importa el rol.
  Paciente? pacienteSeleccionado;

  void seleccionarPaciente(Paciente paciente) {
    pacienteSeleccionado = paciente;
  }

  // Vuelve a pedir a Supabase la lista de pacientes del cuidador logueado.
  // Hay que llamarla después de vincular un paciente nuevo.
  Future<void> recargarPacientesDelCuidador() async {
    if (_cuidadorActual == null) return;
    pacientesDelCuidador = await cuidadorPacienteService
        .obetenerPaciendeDeCuidador(_cuidadorActual!.cuidadorId);

    // si el paciente seleccionado ya no está en la lista (o no había ninguno),
    // seleccionamos el primero disponible.
    if (pacienteSeleccionado == null ||
        !pacientesDelCuidador.any((p) => p.pacienteId == pacienteSeleccionado!.pacienteId)) {
      pacienteSeleccionado = pacientesDelCuidador.isNotEmpty ? pacientesDelCuidador.first : null;
    }
  }

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
          cuidadorId: '', // provisorio: la base genera el id real al insertar
          nombre: nombre,
          email: email,
          fechaNacimiento: fechaNacimiento,
          fotoPerfil: '',
          telefono: telefono ?? '',
          pacientes: [],
        );
        await cuidadorService.crearCuidador(cuidador);
        // releemos desde Supabase para quedarnos con el cuidadorId real
        // (el que generó la base de datos al insertar).
        _cuidadorActual = await cuidadorService.obtenerCuidadorPorUsuarioId(authUser.id);
        _pacienteActual = null;
        pacientesDelCuidador = []; // recién se registró, todavía no tiene pacientes vinculados
        pacienteSeleccionado = null;
      } else {
        final paciente = Paciente(
          id: authUser.id,
          pacienteId: '', // provisorio: la base genera el id real al insertar
          nombre: nombre,
          email: email,
          fechaNacimiento: fechaNacimiento,
          fotoPerfil: '',
          horario: Horario(bloques: []),
        );
        await pacienteService.crearPaciente(paciente);
        // releemos desde Supabase para quedarnos con el pacienteId real
        _pacienteActual = await pacienteService.obtenerPacientePorUsuarioId(authUser.id);
        _cuidadorActual = null;
        pacienteSeleccionado = _pacienteActual; // un paciente siempre "ve" sus propias actividades
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
        await recargarPacientesDelCuidador();
        return true;
      }

      final paciente = await pacienteService.obtenerPacientePorUsuarioId(authUser.id);
      if (paciente != null) {
        _pacienteActual = paciente;
        _cuidadorActual = null;
        pacienteSeleccionado = paciente; // un paciente siempre "ve" sus propias actividades
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
    pacientesDelCuidador = [];
    pacienteSeleccionado = null;
  }
}