import 'package:rutina_app/models/paso.dart';

class Actividad {

  String id;
  String nombre;
  String descripcion;
  String rutaIMG;
  List<Paso> pasos;
  bool completada;
  DateTime? fechaCompletada;

  Actividad({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.rutaIMG,
    required this.pasos,
    this.completada = false,
    this.fechaCompletada,
  });

  void completar() {
    completada = true;
    fechaCompletada = DateTime.now();
  }

  void reiniciar() {
    completada = false;
    fechaCompletada = null;
    for (Paso paso in pasos) {
      paso.reiniciar();
    }
  }

  void agregarPaso(Paso paso) {
    pasos.add(paso);
  }

  bool eliminarPaso(Paso paso) {
    return pasos.remove(paso);
  }

  double porcentajeCompletado() {
    if (pasos.isEmpty) {
      return completada ? 100 : 0;
    }
    int completos = 0;
    for (Paso paso in pasos) {
      if (paso.estaCompleto()) {
        completos++;
      }
    }
    return (completos / pasos.length) * 100;
  }

  void editar({
    String? nuevoNombre,
    String? nuevaDescripcion,
    String? nuevaRutaIMG,
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
  }
}