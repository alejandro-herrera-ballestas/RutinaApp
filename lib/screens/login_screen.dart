import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>  {

  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  @override
  Widget build(BuildContext context)  {
    return  Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: const Text("Rutina App"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Login",
              style: TextStyle(
                fontSize: 40,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 20,
              width: 300,
            ),
            TextFormField(
              controller: usuarioController,
              decoration: InputDecoration(
                labelText: "Usuario",
                hintText: "Ingrese su usuario",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(
              height: 20,
              width: 300,
            ),
            TextFormField(
              controller: contrasenaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contraseña",
                hintText: "Ingrese su contraseña",
                prefixIcon: Icon(Icons.password),
              ),
            )
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



