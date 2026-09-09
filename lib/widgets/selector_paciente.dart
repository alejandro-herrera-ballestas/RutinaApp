import 'package:flutter/material.dart';
import 'package:rutina_app/models/paciente.dart';
import 'package:rutina_app/screens/vincular_paciente_screen.dart';
import 'package:rutina_app/utils/global.dart';

// Selector de paciente, para que un Cuidador con varios pacientes
// elija cuál está viendo/editando. No se muestra si el que inició
// sesión es un Paciente (él siempre ve sus propias actividades).
//
// 'onCambio' se llama cada vez que cambia el paciente seleccionado,
// o cuando se vincula uno nuevo — para que la pantalla que lo use
// (home_screen, calendario_screen, add_activity_screen) recargue
// sus actividades.
class SelectorPaciente extends StatelessWidget {
  final VoidCallback onCambio;

  const SelectorPaciente({super.key, required this.onCambio});

  @override
  Widget build(BuildContext context) {
    if (authService.cuidadorActual == null) {
      return const SizedBox.shrink();
    }

    final pacientes = authService.pacientesDelCuidador;

    if (pacientes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          color: const Color(0xFFFFF3E0),
          child: ListTile(
            leading: const Icon(Icons.person_search),
            title: const Text(
              "Todavía no tienes ningún paciente vinculado",
              style: TextStyle(fontSize: 14),
            ),
            trailing: TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VincularPacienteScreen()),
                );
                onCambio(); // por si quedó vinculado uno nuevo
              },
              child: const Text("Vincular"),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<Paciente>(
        value: authService.pacienteSeleccionado,
        decoration: const InputDecoration(
          labelText: "Paciente",
          prefixIcon: Icon(Icons.person),
        ),
        items: pacientes
            .map((p) => DropdownMenuItem(value: p, child: Text(p.nombre)))
            .toList(),
        onChanged: (paciente) {
          if (paciente == null) return;
          authService.seleccionarPaciente(paciente);
          onCambio();
        },
      ),
    );
  }
}