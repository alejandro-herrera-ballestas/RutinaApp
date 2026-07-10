import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/models/BloqueHorario.dart';

class Horario {

  List<BloqueHorario> bloques;

  Horario({
    required this.bloques,
  });

  // Ordena los bloques según la hora de inicio
  void ordenarPorHora() {
    bloques.sort(
          (a, b) => a.horaInicio.compareTo(b.horaInicio),
    );
  }

  // Agrega un bloque verificando que no existan conflictos
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

  // Elimina un bloque
  bool eliminarBloque(BloqueHorario bloqueEliminar) {
    return bloques.remove(bloqueEliminar);
  }

  // Busca un bloque
  bool buscarBloque(BloqueHorario bloque) {
    return bloques.contains(bloque);
  }

  // Mueve un bloque a una nueva hora
  bool moverBloque(BloqueHorario bloque, DateTime nuevoInicio) {
    Duration duracion = bloque.horaFin.difference(bloque.horaInicio);
    DateTime nuevoFin = nuevoInicio.add(duracion);
    // Verificar conflictos con los demás bloques
    for (BloqueHorario b in bloques) {
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

  // Devuelve la actividad que se está realizando actualmente
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

  // Reorganiza automáticamente el horario
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