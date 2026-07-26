import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rutina_app/models/BloqueHorario.dart';
import 'package:rutina_app/utils/global.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  List<String> _conflictivas = [];

  @override
  void initState() {
    super.initState();
    _regenerarHorario();
  }

  // Reconstruye el horario del día a partir de las actividades actuales
  void _regenerarHorario() {
    final actividades = actividadService.obtenerActividades();
    final conflictos = horarioDelDia.generarDesdeActividades(actividades, DateTime.now(),);

    setState(() {
      _conflictivas = conflictos;
    });
    if (conflictos.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "No se pudieron ubicar: ${conflictos.join(', ')} (conflicto de horario)",
            ),
            backgroundColor: Colors.orange,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fechaHoy = DateFormat("d 'de' MMMM", 'es_ES').format(DateTime.now());
    final List<BloqueHorario> bloques = horarioDelDia.bloques;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Calendario",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index != 1) {
            Navigator.pop(context); 
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Calendario"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Horario",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              fechaHoy,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: bloques.isEmpty
                  ? const Center(
                child: Text(
                  "No hay actividades programadas para hoy.",
                  style: TextStyle(color: Colors.black54),
                ),
              )
                  : ListView.builder(
                itemCount: bloques.length,
                itemBuilder: (context, index) {
                  final bloque = bloques[index];
                  final horaInicio = DateFormat('HH:mm').format(bloque.horaInicio);
                  final horaFin = DateFormat('HH:mm').format(bloque.horaFin);

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(bloque.actividad.nombre),
                      subtitle: Text('$horaInicio - $horaFin'),
                      trailing: bloque.actividad.completada
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}