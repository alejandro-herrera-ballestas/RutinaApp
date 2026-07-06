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
    required super.nombre,
    required super.fechaNacimiento,
    required super.fotoPerfil,
  })

  void agregarPaciente(Paciente nuevoPaciente) {
    for (Paciente pacienteExistente in pacientes) {
      if (pacienteExistente.id == nuevoPaciente.id) {
        print("Actualmente ya hay un paciente con este ID. Imposible registrar.");
        return;
      }
    }

    pacientes.add(nuevoPaciente);
    print("Paciente agregado correctamente.");
  }


}