import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rutina_app/services/actividad_service.dart';
import 'package:rutina_app/widgets/actividadCard.dart';

import 'add_activity_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();  // crear el state de home
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final String fechaHoy = DateFormat("d 'de' MMMM", 'es_ES').format(DateTime.now());    // para mostrar la fecha de hoy
    final ActividadService actividadService = ActividadService();

    final actividades = actividadService.obtenerActividades();    // obtener la lista de actividades

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

      // iconos de navegacion  en la parte inferior
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

      body: Padding(    // cuerpo
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Hoy",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              fechaHoy,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: actividades.length,
                itemBuilder: (context, index) {
                  return ActividadCard(
                      actividad: actividades[index]
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddActivityScreen(),
            ),
          );
        },
        child: const Icon(Icons.add_task),
      ),
    );
  }
}