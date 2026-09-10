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

if (nuevaDescripcion != null && nuevaDescripcion.isNotEmpty) {
descripcion = nuevaDescripcion;
}

if (nuevaRutaIMG != null && nuevaRutaIMG.isNotEmpty) {
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

'hora_inicio':
'${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}:00',

'duracion': '${duracion.inSeconds} seconds',
};
}

factory Actividad.fromMap(Map<String, dynamic> map) {
final horaString = map['hora_inicio'].toString();
final partesHora = horaString.split(':');

final duracionString = map['duracion'].toString();

final partesDuracion = duracionString.split(':');

final horas = int.tryParse(partesDuracion[0]) ?? 0;
final minutos = int.tryParse(partesDuracion[1]) ?? 0;

int segundos = 0;

if (partesDuracion.length >= 3) {
final segundosParte = partesDuracion[2].split('.').first;
segundos = int.tryParse(segundosParte) ?? 0;
}

return Actividad(
id: map['id'].toString(),
nombre: map['nombre']?.toString() ?? '',
descripcion: map['descripcion']?.toString() ?? '',
rutaIMG: map['imagen']?.toString() ?? '',
hora: TimeOfDay(
hour: int.tryParse(partesHora[0]) ?? 0,
minute: int.tryParse(partesHora[1]) ?? 0,
),
duracion: Duration(
hours: horas,
minutes: minutos,
seconds: segundos,
),
);
}
}

