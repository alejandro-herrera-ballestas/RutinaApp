import 'package:flutter/material.dart';
import 'package:rutina_app/screens/home_screen.dart';
import 'package:rutina_app/screens/calendario_screen.dart';
import 'package:rutina_app/screens/perfil_screen.dart';

class MainNavigatorScreen extends StatefulWidget  {
  const MainNavigatorScreen ({super.key});

  @override
  State<MainNavigatorScreen> createState() => _MainNavigatorScreen();
}

class _MainNavigatorScreen extends State<MainNavigatorScreen> {

  int _indiceActual = 0;  // guardar cual pestaña esta seleccionada
  // lista de pantallas
  final List<Widget> _pantallas = [const HomeScreen(), const CalendarioScreen(), const PerfilScreen()];

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      body: _pantallas[_indiceActual],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _indiceActual,
        onTap: (indice)  {
            setState(() {
              _indiceActual = indice;
            });
        },

        // Iconos
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Calendario",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}