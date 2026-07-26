import 'package:flutter/material.dart';

class Actividad {

  String id;
  String nombre;
  String descripcion;
  String rutaIMG;
  bool completada;
  DateTime? fechaCompletada;
  TimeOfDay hora;
  Duration duracion;

  Actividad({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.rutaIMG,
    this.completada = false,
    this.fechaCompletada,
    required this.hora,
    required this.duracion,
  });

  void completar() {
    completada = true;
    fechaCompletada = DateTime.now();
  }

  void reiniciar() {
    completada = false;
    fechaCompletada = null;
  }

  void editar({
    String? nuevoNombre,
    String? nuevaDescripcion,
    String? nuevaRutaIMG,
    TimeOfDay? nuevaHora,
  }) {
    if (nuevoNombre != null && nuevoNombre.isNotEmpty) {
      nombre = nuevoNombre;
    }
    if (nuevaDescripcion != null &&
        nuevaDescripcion.isNotEmpty) {
      descripcion = nuevaDescripcion;
    }
    if (nuevaRutaIMG != null &&
        nuevaRutaIMG.isNotEmpty) {
      rutaIMG = nuevaRutaIMG;
    }
    if (nuevaHora != null)  {
      hora = nuevaHora;
    }
  }
}