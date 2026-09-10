class ProgresoActividad {
  String id;
  String actividadId;
  DateTime fecha;
  bool completada;
  DateTime? horaCompletada;

  ProgresoActividad({
    required this.id,
    required this.actividadId,
    required this.fecha,
    required this.completada,
    this.horaCompletada,
  });

  Map<String, dynamic> toMap() {
    return {
      'actividad_id': actividadId,
      'fecha': fecha.toIso8601String().split('T')[0],
      'completada': completada,
      'hora_completada': horaCompletada?.toIso8601String(),
    };
  }

  factory ProgresoActividad.fromMap(Map<String, dynamic> map) {
    return ProgresoActividad(
      id: map['id'],
      actividadId: map['actividad_id'],
      fecha: DateTime.parse(map['fecha']),
      completada: map['completada'] ?? false,
      horaCompletada: map['hora_completada'] != null
          ? DateTime.parse(map['hora_completada'])
          : null,
    );
  }
}
