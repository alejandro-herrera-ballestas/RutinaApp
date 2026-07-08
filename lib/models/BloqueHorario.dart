import 'package:flutter/material.dart';
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


}