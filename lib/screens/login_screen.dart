import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
  final TextEditingController UsuarioController = TextEditingController();
  final TextEditingController con
}

class _LoginScreenState extends State<LoginScreen>  {
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
          ],
        ),
      ),
    );
  }
}

