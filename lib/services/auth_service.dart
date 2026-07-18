import 'package:rutina_app/services/usuarioAuth.dart';

class AuthService {

  final List<UsuarioAuth> _usuarios = [];

  bool registrarUsuario(String nombre, String usuario, String contrasena) {

    for (var u in _usuarios) {      // verificar si el usuario ya existe
      if (u.usuario == usuario) {
        return false;
      }
    }
    _usuarios.add(
      UsuarioAuth(
        nombre: nombre,
        usuario: usuario,
        contrasena: contrasena,
      ),
    );

    return true;
  }

  bool iniciarSesion(String usuario, String contrasena) {

    for (var u in _usuarios) {
      if (u.usuario == usuario && u.contrasena == contrasena) {
        return true;
      }
    }
    return false;
  }

  void cerrarSesion() {
  }

}