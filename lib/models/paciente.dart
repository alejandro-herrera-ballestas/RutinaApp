import 'package:rutina_app/models/BloqueHorario.dart';
import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/models/horario.dart';
import 'package:rutina_app/models/usuario.dart';

class Paciente extends Usuario  {
  Horario horario;
  List<Actividad>actividadesCompletadas;

  Paciente({
    required this.horario,
    required this.actividadesCompletadas,
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
}