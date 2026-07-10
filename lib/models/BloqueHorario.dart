import 'package:rutina_app/models/actividad.dart';

class BloqueHorario {

  DateTime horaInicio;
  DateTime horaFin;
  Actividad actividad;

  BloqueHorario({
    required this.horaInicio,
    required this.horaFin,
    required this.actividad,
  });

  Duration calcularDuracion() {
    return horaFin.difference(horaInicio);
  }

  void cambiarHoraInicio(DateTime nuevoInicio) {
    horaInicio = nuevoInicio;
  }

  void cambiarHoraFin(DateTime nuevoFinal) {
    horaFin = nuevoFinal;
  }

  void cambiarActividad(Actividad nuevaActividad) {
    actividad = nuevaActividad;
  }
}