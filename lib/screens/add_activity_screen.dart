import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:rutina_app/utils/global.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {

  final ImagePicker _picker = ImagePicker();
  File? _imagenSeleccionada;
  final TextEditingController nombreActividadController = TextEditingController();
  final TextEditingController descripcionActividadController = TextEditingController();
  final TextEditingController horaActividadController = TextEditingController();

  TimeOfDay? _horaSeleccionada;

  // ============================ Selección de hora (TimePicker) ============================
  Future<void> _seleccionarHora() async {
    final TimeOfDay? horaElegida = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
    );

    if (horaElegida == null) return;

    setState(() {
      _horaSeleccionada = horaElegida;
      final horas = horaElegida.hour.toString().padLeft(2, '0');
      final minutos = horaElegida.minute.toString().padLeft(2, '0');
      horaActividadController.text = '$horas:$minutos';
    });
  }

  // ============================ Selección/captura de imagen ============================
  Future<void> _seleccionarImagen() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Tomar foto"),
                onTap: () async {
                  Navigator.pop(context);

                  final XFile? imagen = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );

                  if (imagen == null) return;

                  setState(() {
                    _imagenSeleccionada = File(imagen.path);
                  });
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Elegir de la galería"),
                onTap: () async {
                  Navigator.pop(context);

                  final XFile? imagen = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );

                  if (imagen == null) return;

                  setState(() {
                    _imagenSeleccionada = File(imagen.path);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================ Guardar actividad ============================
  void _guardarActividad() {
    // 1. Leer los valores actuales de los controladores
    final nombre = nombreActividadController.text.trim();
    final descripcion = descripcionActividadController.text.trim();
    final hora = horaActividadController.text.trim();

    if (nombre.isEmpty || hora.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa al menos el nombre y la hora de la actividad'),
        ),
      );
      return;
    }
// 3. Aquí se llamará al servicio para persistir la actividad, por ejemplo:
    // ActividadService.agregarActividad(
    //   nombre: nombre,
    //   descripcion: descripcion,
    //   hora: hora,
    // );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2), // color de fondo
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5), // color del appBar
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Nueva Actividad",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black87),
            tooltip: 'Guardar actividad',
            onPressed: _guardarActividad,
          ),
        ],
      ),

      // ================================ navegación inferior ========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Calendario"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),

      // ============================ Cuerpo del formulario ==================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ------------------ Selector de imagen (interactivo) ------------------
                  GestureDetector(
                    onTap: _seleccionarImagen,
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: _imagenSeleccionada == null
                          ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 45,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Agregar imagen",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imagenSeleccionada!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ------------------ Nombre de la actividad ------------------
                  TextFormField(
                    controller: nombreActividadController,
                    decoration: const InputDecoration(
                      labelText: "Nombre de la actividad",
                      hintText: "Ej: Cepillarse los dientes",
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------ Descripción (opcional) ------------------
                  TextFormField(
                    controller: descripcionActividadController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Descripción (Opcional)",
                      hintText: "Ej: Cepíllate los dientes después del desayuno",
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------ Hora de la actividad (TimePicker) ------------------
                  TextFormField(
                    controller: horaActividadController,
                    readOnly: true, // el usuario no escribe manualmente, solo selecciona
                    onTap: _seleccionarHora,
                    decoration: const InputDecoration(
                      labelText: "Ingrese la hora de la actividad",
                      hintText: "Ej: 8:00",
                      suffixIcon: Icon(Icons.access_time_filled),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ------------------ Botón principal de guardar ------------------
                  ElevatedButton.icon(
                    onPressed: _guardarActividad,
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar actividad"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nombreActividadController.dispose();
    descripcionActividadController.dispose();
    horaActividadController.dispose();
    super.dispose();
  }
}