import 'package:rutina_app/models/paso.dart';

class Actividad {

  String id;
  String nombre;
  String descripcion;
  bool completada;
  String rutaIMG;   // ruta de la imagen (galeria o tomar foto)
  Duration duracion;
  List<Paso> pasos;

  Actividad({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.rutaIMG,
    required this.completada,
    required this.duracion,
    required this.pasos,
  });

  void completar() {
    completada = true;
  }

  void reiniciar()  {
    completada = false;
  }

  void agregarPaso(Paso p)  {
    pasos.add(p);
  }

  void eliminarPaso(Paso p) {
    pasos.remove(p);
  }
}