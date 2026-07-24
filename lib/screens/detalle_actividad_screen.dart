import 'package:flutter/material.dart';

class DetalleActividadScreen extends StatefulWidget {
  const DetalleActividadScreen ({super.key});

  @override
  State<DetalleActividadScreen> createState ()  => _DetalleActividadScreen();
}

class _DetalleActividadScreen extends State<DetalleActividadScreen> {
  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(
            "Editar Actividad",
        style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: const Color(0xFFF8F5F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            actions: [
              IconButton(
                icon: const Icon(Icons.check),   // icono check
                onPressed: () {},
              ),
            ];
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Calendario"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}