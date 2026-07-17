import 'package:flutter/material.dart';
import 'login_screen.dart';

class registerScreen extends StatefulWidget{
  const registerScreen({super.key});
  @override
  State<registerScreen> createState() => _registerScreenState();  // crear el state de registger
}

class _registerScreenState extends State<registerScreen>  {

  bool ocultarConfirmacion = true;
  bool ocultarContra = true;
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();    // controladores para guardar los datos
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmContrasenaController = TextEditingController();

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
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

      body: Center(   // seccion de registro
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Registro",
              style: TextStyle(
                fontSize: 40,
                color: Colors.black87,
                fontWeight: FontWeight.normal,
              ),
            ),

            SizedBox(
              height: 60,
            ),

            SizedBox(   // registrar nombre
              width: 300,
              child: TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre completo",
                  hintText: "Ingrese su nombre completo",
                ),
              ),
            ),

            SizedBox(     // registrar usuario
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

            SizedBox(   // registrar contraseña
                width: 300,
                child: TextFormField(
                  controller: contrasenaController,
                  obscureText: ocultarContra,
                  decoration:  InputDecoration(
                    labelText: "Contraseña",
                    hintText: "Ingrese su contraseña",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          ocultarContra = !ocultarContra;
                        });
                      },
                      icon: Icon(
                        ocultarContra
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
            ),

            SizedBox(
              height: 30,
            ),

            SizedBox(   // confirmar contraseña
              width: 300,
              child: TextFormField(
                controller: confirmContrasenaController,
                obscureText: ocultarConfirmacion,
                decoration:  InputDecoration(
                  labelText: "Confirmar Contraseña",
                  hintText: "Confirme su contraseña",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarConfirmacion = !ocultarConfirmacion;
                      });
                    },
                    icon: Icon(
                      ocultarConfirmacion
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 30,
            ),

            SizedBox(   // boton registro
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final nombreCompleto = nombreController.text;
                  final usuario = usuarioController.text;
                  final contrasena = contrasenaController.text;
                  final confirmarContra = confirmContrasenaController.text;

                  // confirmar que no haya campos vacios
                  if (usuario.isEmpty || contrasena.isEmpty || nombreCompleto.isEmpty || confirmarContra.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Debe completar todos los campos."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (contrasena != confirmarContra) {  // confirmar que las contraseñas sean iguales
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Las contraseñas no coinciden."),
                        backgroundColor: Colors.red,
                      ),
                    );

                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(   // mensaje de exito
                    const SnackBar(
                      content: Text("Usuario registrado correctamente."),
                      backgroundColor: Colors.green,
                    ),
                  );
                  print("Usuario: $usuario, Contraseña: $contrasena");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6D8B74),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Registrarse",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "¿Ya tienes cuenta? Inicia sesion aqui",
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
  void dispose() {
    nombreController.dispose();
    usuarioController.dispose();
    contrasenaController.dispose();
    confirmContrasenaController.dispose();
    super.dispose();
  }
}