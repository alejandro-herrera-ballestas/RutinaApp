import 'dart:ffi';

import 'package:rutina_app/models/paso.dart';

class Actividad {

  Int id;
  String titulo;
  String descripcion;
  String horaInicio;
  String horaFinal;
  bool estado;
  List<Paso>pasos;

  Actividad({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.horaInicio,
    required this.horaFinal,
    required this.estado,
    required this.pasos,
});
}