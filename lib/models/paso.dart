class Paso  {
  int id;
  int orden;
  String descripcion;
  bool completado;

  Paso({
    required this.id,
    required this.orden,
    required this.descripcion,
    this.completado = false,
  });

  void completar()  {
    completado = true;
  }

  void reiniciar()  {
    completado = false;
  }

  bool estaCompleto() {
    return completado;
  }
}