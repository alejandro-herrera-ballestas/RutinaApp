import 'package:rutina_app/models/actividad.dart';

class ActividadService {
  final List<Actividad> _actividades = [];

  // Agregar una nueva actividad
  bool agregarActividad(Actividad actividad) {
    // Verificar que no exista una actividad con el mismo id
    for (Actividad a in _actividades) {
      if (a.id == actividad.id) {
        return false;
      }
    }
    _actividades.add(actividad);
    return true;
  }

  // Obtener todas las actividades
  List<Actividad> obtenerActividades() {
    return List.from(_actividades);
  }

  // Buscar una actividad por su id
  Actividad? buscarActividad(String id) {
    for (Actividad a in _actividades) {
      if (a.id == id) {
        return a;
      }
    }
    return null;
  }

  // Editar una actividad
  bool editarActividad(
      String id, {
        String? nombre,
        String? descripcion,
        String? rutaIMG,
      }) {
    Actividad? actividad = buscarActividad(id);
    if (actividad == null) {
      return false;
    }
    actividad.editar(
      nuevoNombre: nombre,
      nuevaDescripcion: descripcion,
      nuevaRutaIMG: rutaIMG,
    );
    return true;
  }

  // Eliminar una actividad
  bool eliminarActividad(String id) {
    Actividad? actividad = buscarActividad(id);
    if (actividad == null) {
      return false;
    }
    _actividades.remove(actividad);
    return true;
  }

  // Reordenar actividades (pensado para el onReorder de un ReorderableListView)
  bool reordenarActividades(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _actividades.length ||
        newIndex < 0 ||
        newIndex > _actividades.length) {
      return false;
    }
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    Actividad actividad = _actividades.removeAt(oldIndex);
    _actividades.insert(newIndex, actividad);
    return true;
  }

  // Marcar una actividad como completada
  bool completarActividad(String id) {
    Actividad? actividad = buscarActividad(id);
    if (actividad == null) {
      return false;
    }
    if (actividad.completada) {
      return false;
    }
    actividad.completar();
    return true;
  }

  // Reiniciar una actividad
  bool reiniciarActividad(String id) {
    Actividad? actividad = buscarActividad(id);
    if (actividad == null) {
      return false;
    }
    actividad.reiniciar();
    return true;
  }

  // Obtener porcentaje de una actividad
  double obtenerPorcentaje(String id) {
    Actividad? actividad = buscarActividad(id);
    if (actividad == null) {
      return 0;
    }
    return actividad.porcentajeCompletado();
  }

  int cantidadActividades() {
    return _actividades.length;
  }

  // Eliminar todas las actividades
  void limpiarActividades() {
    _actividades.clear();
  }

  int actividadesCompletadas() {

    int contador = 0;

    for (Actividad actividad in _actividades) {
      if (actividad.completada) {
        contador++;
      }
    }
    return contador;
  }
}