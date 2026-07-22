import 'package:flutter/material.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreen();  // crear el state de home
}

class _AddActivityScreen extends State<AddActivityScreen>  {
  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2), // color de fondo
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),   // color del appBar
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu), // icon de menu
          onPressed: () {},
        ),
        title: const Text(
          "RutinaApp",
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

      // ================================ iconos de navegacion  en la parte inferior ========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const  [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Calendario"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),

      // ============================ Cuerpo ==================================
      body: Column(

      ),
    );
  }
}