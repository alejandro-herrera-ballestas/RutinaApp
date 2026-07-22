import 'package:flutter/material.dart';
import 'package:rutina_app/screens/home_screen.dart';
import 'package:rutina_app/utils/global.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();  // crear el state de login
}

class _LoginScreenState extends State<LoginScreen>  {

  final TextEditingController usuarioController = TextEditingController();    // controladores para guardar los datos
  final TextEditingController contrasenaController = TextEditingController();
  bool ocultarContrasena = true;

  @override
  Widget build(BuildContext context)  {
    return  Scaffold(
      backgroundColor: const Color(0xFFF8F5F2), // color de fondo
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),   // barra
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Rutina App",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 1.2,
          ),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month,
              size: 90,
            ),
            const Text(
              "Bienvenido",
              style: TextStyle(
                fontSize: 40,
                color: Colors.black87,
                fontWeight: FontWeight.normal,
              ),
            ),

            SizedBox(
              height: 60,
            ),

            SizedBox(     // espacio para poner el usuario
              width: 300,
              child: TextFormField(
                controller: usuarioController,
                decoration: const InputDecoration(
                  labelText: "Usuario",
                  hintText: "Ingrese su usuario",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),

            SizedBox(
                height: 20
            ),

             SizedBox(    // espacio para poner la contrasena
              width: 300,
                child: TextFormField(

                  controller: contrasenaController,
                  obscureText: ocultarContrasena,
                  decoration:  InputDecoration(
                    labelText: "Contraseña",
                    hintText: "Ingrese su contraseña",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          ocultarContrasena = !ocultarContrasena;
                        });
                      },
                      icon: Icon(
                        ocultarContrasena
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                )
            ),

            SizedBox(
              height: 30,
            ),
            
            SizedBox(   // boton iniciar sesion
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final usuario = usuarioController.text;
                  final contrasena = contrasenaController.text;

                  if (usuario.isEmpty || contrasena.isEmpty) {  // verificar que no esten los campos vacios
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Debe completar todos los campos."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  bool loginExitoso = authService.iniciarSesion(
                    usuario,
                    contrasena,
                  );

                  if (!loginExitoso) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Usuario o contraseña incorrectos"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (loginExitoso == true) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen(),
                      ),
                    );
                  }

                  ScaffoldMessenger.of(context).showSnackBar(   // mensaje de exito
                    const SnackBar(
                      content: Text("Inicio de sesion con exito."),
                      backgroundColor: Colors.green,
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6D8B74),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Iniciar sesión",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 15),

// BOTÓN REGISTRARSE
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const registerScreen(),),);
              },
              child: const Text(
                "¿No tienes cuenta? Regístrate",
                style: TextStyle(
                  color: Colors.black87,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose(){
    usuarioController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }
}



