import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/models/horario.dart';
import 'package:rutina_app/models/paciente.dart';

class DatabaseService {

  // PACIENTES

  void guardarPaciente(Paciente paciente) {}

  void actualizarPaciente(Paciente paciente) {}

  void eliminarPaciente(Paciente paciente) {}

  List<Paciente> obtenerPacientes() {
    return [];
  }

  // ACTIVIDADES

  void guardarActividad(Actividad actividad) {}

  void actualizarActividad(Actividad actividad) {}

  void eliminarActividad(Actividad actividad) {}

  List<Actividad> obtenerActividades() {
    return [];
  }

  // HORARIOS

  void guardarHorario(Horario horario) {}

  void actualizarHorario(Horario horario) {}

  Horario? obtenerHorario(Paciente paciente) {
    return null;
  }

}