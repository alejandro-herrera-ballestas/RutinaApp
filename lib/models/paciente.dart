import 'package:rutina_app/models/BloqueHorario.dart';
import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/models/horario.dart';
import 'package:rutina_app/models/usuario.dart';

class Paciente extends Usuario  {
  Horario horario;

  Paciente({
    required this.horario,
    // hereda de usuario
    required super.nombre,
    required super.id,
    required super.fechaNacimiento,
    required super.fotoPerfil,
  });

  bool completarActividad(Actividad actividad) {
    if (actividad.completada) {
      return false;
    }
    actividad.completar();
    return true;
  }

  void reiniciarActividades() {
    for (BloqueHorario bloque in horario.bloques) {
      bloque.actividad.reiniciar();
    }
  }

  double obtenerProgreso() {
    int total = horario.bloques.length;
    if (total == 0) {
      return 0;
    }
    int completadas = 0;
    for (BloqueHorario bloque in horario.bloques) {
      if (bloque.actividad.completada) {
        completadas++;
      }
    }
    return (completadas / total) * 100;
  }

  String mostrarInfo()  {
    return '''
    ID: $id
    Nombre: $nombre
    Edad: ${obtenerEdad()}
    Foto: $fotoPerfil
    ''';
  }
}