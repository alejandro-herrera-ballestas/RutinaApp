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
    Duration? nuevaDuracion,
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

    if (nuevaHora != null) {
      hora = nuevaHora;
    }

    if (nuevaDuracion != null) {
      duracion = nuevaDuracion;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen': rutaIMG,
      'hora':
      '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}',
      'duracion': duracion.inSeconds,
    };
  }

  factory Actividad.fromMap(Map<String, dynamic> map) {
    final partesHora = map['hora'].toString().split(':');

    return Actividad(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      rutaIMG: map['imagen'] ?? '',
      hora: TimeOfDay(
        hour: int.parse(partesHora[0]),
        minute: int.parse(partesHora[1]),
      ),
      duracion: Duration(
        seconds: map['duracion'],
      ),
    );
  }
}