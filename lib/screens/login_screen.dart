import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>  {
  @override
  Widget build(BuildContext context)  {
    return  Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: Center(
        child: Text("INICIAR SESION",
        style: TextStyle(fontSize: 40,color: Colors.black87),
        ),
      ),
    );
  }
}

