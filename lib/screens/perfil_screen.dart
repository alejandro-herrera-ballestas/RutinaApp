import 'package:flutter/material.dart';

class PerfilScreen extends StatefulWidget  {
  const PerfilScreen ({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreen();
}

class _PerfilScreen extends State<PerfilScreen> {
  @override
  Widget build(BuildContext context)  {
    return Scaffold(
    backgroundColor: const Color(0xFFF8F5F2), // color de fondo
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFFBF5),   // color del appBar
      elevation: 0,
      centerTitle: true,
      title: const Text(
      "Perfil",
      style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
        ),
      ),
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications_none),   // icono notificacion
        onPressed: () {},
         ),
        ],
      ),

      body: Padding(
          padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

          ],
        ),
      ),
    );
  }
}