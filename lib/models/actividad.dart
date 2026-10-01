import 'package:flutter/material.dart';

class Actividad {
  String id;
  String pacienteId; // paciente dueño de la actividad (columna paciente_id)
  String nombre;
  String descripcion;

  // Ruta del archivo DENTRO del bucket 'actividades' de Supabase Storage
  // (ej: "{pacienteId}/{uuid}.jpg"). Ya NO es una ruta local del celular.
  String rutaIMG;

  bool completada;
  DateTime? fechaCompletada;

  TimeOfDay hora;
  Duration duracion;

  // Días de la semana en que se repite: 1 = lunes ... 7 = domingo
  // (igual que DateTime.weekday).
  List<int> diasSemana;

  static const List<int> todosLosDias = [1, 2, 3, 4, 5, 6, 7];

  Actividad({
    required this.id,
    this.pacienteId = '',
    required this.nombre,
    required this.descripcion,
    required this.rutaIMG,
    this.completada = false,
    this.fechaCompletada,
    required this.hora,
    required this.duracion,
    List<int>? diasSemana,
  }) : diasSemana = diasSemana ?? List<int>.from(todosLosDias);

  // ¿La actividad se hace en la fecha indicada?
  bool ocurreEn(DateTime fecha) {
    return diasSemana.contains(fecha.weekday);
  }

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
    List<int>? nuevosDias,
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

    if (nuevosDias != null && nuevosDias.isNotEmpty) {
      diasSemana = nuevosDias;
    }
  }

  Map<String, dynamic> toMap() {
    final List<int> dias = List<int>.from(diasSemana);
    dias.sort();

    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen': rutaIMG,
      'hora_inicio':
          '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}:00',
      'duracion': '${duracion.inSeconds} seconds',
      'dias_semana': dias,
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

    // dias_semana llega como lista de números desde Postgres
    final List<int> dias = [];
    final diasCrudos = map['dias_semana'];
    if (diasCrudos is List) {
      for (final d in diasCrudos) {
        final numero = int.tryParse(d.toString());
        if (numero != null) {
          dias.add(numero);
        }
      }
    }
    if (dias.isEmpty) {
      dias.addAll(todosLosDias);
    }

    return Actividad(
      id: map['id'].toString(),
      pacienteId: map['paciente_id']?.toString() ?? '',
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
      diasSemana: dias,
    );
  }
}
