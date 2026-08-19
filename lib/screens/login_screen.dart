import 'package:flutter/material.dart';
import 'package:rutina_app/screens/main_navigator_screen.dart';
import 'package:rutina_app/utils/global.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();  // crear el state de login
}

class _LoginScreenState extends State<LoginScreen>  {

  final TextEditingController emailController = TextEditingController();    // controladores para guardar los datos
  final TextEditingController contrasenaController = TextEditingController();
  bool ocultarContrasena = true;
  bool cargando = false; // evita doble tap mientras se consulta a Supabase

  Future<void> _iniciarSesion() async {
    final email = emailController.text.trim();
    final contrasena = contrasenaController.text;

    if (email.isEmpty || contrasena.isEmpty) {  // verificar que no esten los campos vacios
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debe completar todos los campos."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final bool loginExitoso = await authService.iniciarSesion(
        email,
        contrasena,
      );

      if (!mounted) return;

      if (!loginExitoso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Correo o contraseña incorrectos."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(   // mensaje de exito
        const SnackBar(
          content: Text("Inicio de sesion con exito."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigatorScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No se pudo iniciar sesión: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

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
        child: SingleChildScrollView(
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

              SizedBox(     // espacio para poner el correo
                width: 300,
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Correo electrónico",
                    hintText: "Ingrese su correo electrónico",
                    prefixIcon: Icon(Icons.email_outlined),
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
                  onPressed: cargando ? null : _iniciarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6D8B74),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: cargando
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Iniciar sesión",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 15),

// BOTÓN REGISTRARSE
              TextButton(
                onPressed: cargando
                    ? null
                    : () {
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
      ),
    );
  }

  @override
  void dispose(){
    emailController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }
}



