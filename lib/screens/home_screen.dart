import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/paciente.dart';
import '../services/paciente_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PacienteService _pacienteService = PacienteService();

  bool _isLoading = true;
  List<Paciente> _pacientes = [];
  Paciente? _pacienteSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    final String? userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Se utiliza el nombre correcto del método en PacienteService
    final pacientesObtenidos = await _pacienteService.obtenerPacientesDeCuidador(userId);

    setState(() {
      _pacientes = pacientesObtenidos;
      if (_pacientes.isNotEmpty) {
        _pacienteSeleccionado = _pacientes.first;
      } else {
        _pacienteSeleccionado = null;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - RutinaApp'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _cargarDatosIniciales,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SELECTOR / INFORMACIÓN DEL PACIENTE ACTIVO ---
              if (_pacienteSeleccionado != null) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          child: Icon(Icons.person, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pacienteSeleccionado!.nombre,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${_pacienteSeleccionado!.id}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_pacientes.length > 1)
                          DropdownButton<String>(
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down),
                            value: _pacienteSeleccionado!.id,
                            items: _pacientes.map((p) {
                              return DropdownMenuItem<String>(
                                value: p.id,
                                child: Text(p.nombre),
                              );
                            }).toList(),
                            onChanged: (nuevoId) {
                              if (nuevoId != null) {
                                setState(() {
                                  _pacienteSeleccionado = _pacientes.firstWhere(
                                        (element) => element.id == nuevoId,
                                  );
                                });
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- RESUMEN DE ACTIVIDADES / RUTINAS ---
                const Text(
                  'Rutina Diaria',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Tarjetas de actividades asociadas al paciente activo
              ] else ...[
                // --- ESTADO SIN PACIENTE VINCULADO ---
                Card(
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 48,
                          color: Colors.orange,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No tienes ningún paciente vinculado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Para ver las rutinas e información, ve a tu Perfil y vincula a un paciente mediante su identificador.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
