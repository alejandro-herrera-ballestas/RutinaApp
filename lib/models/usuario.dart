import  'dart:io';    // stdin.readLineSync para leer

abstract class Usuario {
  String id;
  String nombre;
  DateTime fechaNacimiento;
  String? fotoPerfil;

  Usuario({
    required this.nombre,
    required this.fechaNacimiento,
    required this.fotoPerfil,
    required this.id;
  });

  void obtenerEdad () {
    print("Ingrese su fecha de nacimiento en formato yyyy-mm-dd: ");
    String? leerNacimiento = stdin.readLineSync();

    try {
    
    fechaNacimiento = DateTime.parse(leerNacimiento!); // convertir String a fecha
    print("Fecha de nacimiento registrada!");
      DateTime hoy = DateTime.now();
      
      int edad = hoy.year - fechaNacimiento.year; // calcular edad
      if (edad < 0) {
        print("La fecha de nacimiento ingresada es futura. Por favor, ingrese una fecha válida.");
        return;
      } else if (edad > 150) {
        print("La edad calculada es mayor a 150 años. Por favor, ingrese una fecha válida.");
        return;
      } 

    } catch (e) {

      print("Ingrese un formato valido");
      return;
      }
    }

    void cambiarNombre () {
    print("Ingrese su nuevo nombre: ");
    String? leerNombre = stdin.readLineSync();
    if (leerNombre != null && leerNombre.isNotEmpty) {
      nombre = leerNombre;
      print("Nombre actualizado a: $nombre");
    } else {
      print("Nombre no puede estar vacío.");
    }
  }

  void preguntarID  ()  {
    print("Ingrese el ID del usuario: ");
    String? leerIdUsuario = stdin.readLineSync();
    if(leerIdUsuario != null && leerIdUsuario.isNotEmpty) {
      id = leerIdUsuario;
      print("Nombre actualizado a: $id");
    }
  }

  void cambiarFotoPerfil () {
    print("Ingrese la ruta de su nueva foto de perfil: ");
    String? leerFoto = stdin.readLineSync();
    if (leerFoto != null && leerFoto.isNotEmpty) {
      fotoPerfil = leerFoto;
      print("Foto de perfil actualizada a: $fotoPerfil");
    } else {
      print("Ruta de foto no puede estar vacía.");
    }
  }

  void mostrarInformacion(){}


}