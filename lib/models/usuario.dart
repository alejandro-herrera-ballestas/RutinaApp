abstract class Usuario {
  String id;
  String nombre;
  DateTime fechaNacimiento;
  String? fotoPerfil;

  Usuario({
    required this.nombre,
    required this.fechaNacimiento,
    required this.fotoPerfil,
    required this.id,
  });

  int obtenerEdad() {
    DateTime hoy = DateTime.now();
    int edad = hoy.year - fechaNacimiento.year;

    if (hoy.month < fechaNacimiento.month || (hoy.month == fechaNacimiento.month && hoy.day < fechaNacimiento.day)) {
      edad--;
    }
    return edad;
  }

  void cambiarNombre(String nuevoNombre) {
    if (nuevoNombre.isNotEmpty) {
      nombre = nuevoNombre;
    }
  }

  void cambiarId(String nuevoId) {
    if (nuevoId.isNotEmpty) {
      id = nuevoId;
    }
  }

  void cambiarFotoPerfil(String nuevaRuta) {
    if (nuevaRuta.isNotEmpty) {
      fotoPerfil = nuevaRuta;
    }
  }

  String mostrarInformacion() {
    return '''
    ID: $id
    Nombre: $nombre
    Edad: ${obtenerEdad()}
    Foto: $fotoPerfil
    ''';
  }

}