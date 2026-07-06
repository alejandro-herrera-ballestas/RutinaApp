import 'package:rutina_app/models/actividad.dart';

class Rutina {
  String nombre;
  DateTime diaSemana;
  List<Actividad> actividades;

  Rutina({
    required this.nombre,
    required this.diaSemana,
    required this.actividades,
  });

}