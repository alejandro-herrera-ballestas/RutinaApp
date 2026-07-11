import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/models/BloqueHorario.dart';

class Horario {

  List<BloqueHorario> bloques;

  Horario({
    required this.bloques,
  });

  void ordenarPorHora() {
    bloques.sort((a, b) => a.horaInicio.compareTo(b.horaInicio),
    );
  }

  bool agregarBloque(BloqueHorario nuevoBloque) {
    for (BloqueHorario bloque in bloques) {
      if (nuevoBloque.horaInicio.isBefore(bloque.horaFin) &&
          nuevoBloque.horaFin.isAfter(bloque.horaInicio)) {
        return false;
      }
    }
    bloques.add(nuevoBloque);
    ordenarPorHora();
    return true;
  }

  bool eliminarBloque(BloqueHorario bloqueEliminar) {
    return bloques.remove(bloqueEliminar);
  }

  bool buscarBloque(BloqueHorario bloque) {
    return bloques.contains(bloque);
  }

  bool moverBloque(BloqueHorario bloque, DateTime nuevoInicio) {
    Duration duracion = bloque.horaFin.difference(bloque.horaInicio);
    DateTime nuevoFin = nuevoInicio.add(duracion);
    for (BloqueHorario b in bloques) {    // verificar si hay conflitos
      if (b == bloque) continue;
      if (nuevoInicio.isBefore(b.horaFin) && nuevoFin.isAfter(b.horaInicio)) {
        return false;
      }
    }
    bloque.horaInicio = nuevoInicio;
    bloque.horaFin = nuevoFin;
    ordenarPorHora();
    return true;
  }

  Actividad? obtenerActividadActual() {
    DateTime ahora = DateTime.now();
    for (BloqueHorario bloque in bloques) {
      if (!ahora.isBefore(bloque.horaInicio) &&
          ahora.isBefore(bloque.horaFin)) {
        return bloque.actividad;
      }
    }
    return null;
  }

  void ajustarHorario() {
    ordenarPorHora();
    for (int i = 1; i < bloques.length; i++) {
      BloqueHorario anterior = bloques[i - 1];
      BloqueHorario actual = bloques[i];
      Duration duracion =
      actual.horaFin.difference(actual.horaInicio);
      actual.horaInicio = anterior.horaFin;
      actual.horaFin = actual.horaInicio.add(duracion);
    }
  }
}