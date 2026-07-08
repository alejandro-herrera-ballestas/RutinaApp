import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/models/usuario.dart';

class Cuidador extends Usuario {

  String correo;
  String telefono;
  List<Paciente> pacientes;

  Cuidador({

    required this.correo,
    required this.telefono,
    required this.pacientes,

    // extiende de usuario:
    required super.nombre,
    required super.fechaNacimiento,
    required super.fotoPerfil,
    required super.id,
  });

  bool agregarPaciente(Paciente nuevoPaciente) {
    for (Paciente pacienteExistente in pacientes) {
      if (pacienteExistente.id == nuevoPaciente.id) {
        return false; // se encontraron 2 iguales... no se agrega
      }
    }
    pacientes.add(nuevoPaciente);
    return true; // no se encontraron 2 iguales
  }

  bool eliminarPaciente(Paciente paciente) {
    for (int i = 0; i < pacientes.length; i++) {
      if (pacientes[i].id == paciente.id) {
        pacientes.removeAt(i);
        return true;
      }
    }
    return false;
  }

  void editarActividad(
      Actividad a, {
        String? id,
        String? nombre,
        String? descripcion,
        String? rutaIMG,
      }) {

    if (id != null) a.id = id;
    if (nombre != null) a.nombre = nombre;
    if (descripcion != null) a.descripcion = descripcion;
    if (rutaIMG != null) a.rutaIMG = rutaIMG;
  }
}