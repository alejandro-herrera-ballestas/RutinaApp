import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/screens/detalle_actividad_screen.dart';
import 'package:rutina_app/widgets/actividadCard.dart';
import 'package:rutina_app/widgets/selector_paciente.dart';
import 'package:rutina_app/utils/global.dart';
import 'add_activity_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Actividad> _actividades = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  // Trae las actividades del paciente seleccionado (el propio paciente,
  // o el que el cuidador tenga elegido) ya combinadas con el progreso de hoy.
  Future<void> _cargarActividades() async {
    final pacienteId = authService.pacienteSeleccionado?.pacienteId;

    setState(() {
      _cargando = true;
      _error = null;
    });

    if (pacienteId == null) {
      setState(() {
        _actividades = [];
        _cargando = false;
      });
      return;
    }

    try {
      final actividades = await actividadService.obtenerActividadesConProgreso(
        pacienteId,
        DateTime.now(),
      );
      if (!mounted) return;
      setState(() {
        _actividades = actividades;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "No se pudieron cargar las actividades: $e";
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fechaHoy = DateFormat("d 'de' MMMM", 'es_ES').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        centerTitle: true,
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
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),

      body: Padding(
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

            // Solo aparece para cuidadores con más de un paciente.
            SelectorPaciente(onCambio: _cargarActividades),

            const SizedBox(height: 10),

            if (_cargando)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              )
            else if (_actividades.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      "No hay actividades para hoy.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _actividades.length,
                    itemBuilder: (context, index) {
                      return ActividadCard(
                        actividad: _actividades[index],

                        onTap: () async {
                          final actualizado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalleActividadScreen(
                                actividad: _actividades[index],
                              ),
                            ),
                          );

                          if (actualizado == true) {
                            _cargarActividades();
                          }
                        },
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context, MaterialPageRoute(
            builder: (_) => const AddActivityScreen(),
          ),
          );
          if (resultado == true) {
            _cargarActividades();
          }
        },
        child: const Icon(Icons.add_task),
      ),
    );
  }
}
