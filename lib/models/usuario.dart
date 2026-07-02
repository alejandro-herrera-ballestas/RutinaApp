import 'dart:ffi';

abstract class Usuario {
  String id;
  String nombre;
  Int edad;

  Usuario({
    required this.id,
    required this.nombre,
    required this.edad,
  });

}