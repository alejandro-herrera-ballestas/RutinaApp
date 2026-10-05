// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rutina_app/utils/global.dart';
import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/services/actividad_service.dart';
import 'package:rutina_app/widgets/selector_dias.dart';

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
  Duration _duracionSeleccionada = const Duration(minutes: 15); // valor inicial por defecto

  // NUEVO: días de la semana en que se repite (por defecto, todos)
  List<int> _diasSeleccionados = List<int>.from(Actividad.todosLosDias);

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

                  // maxWidth/maxHeight reducen el tamaño: los buckets
                  // aceptan imágenes de hasta 2 MB.
                  final XFile? imagen = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                    maxWidth: 1280,
                    maxHeight: 1280,
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
                    maxWidth: 1280,
                    maxHeight: 1280,
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

  bool _guardando = false;

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  // ============================ Guardar actividad ============================
  Future<void> _guardarActividad() async {
    // NUEVO: evita guardar dos veces si se toca el botón rápido
    if (_guardando) return;

    // Solo un cuidador puede asignar actividades (el paciente no se las
    // asigna a sí mismo). La base de datos también lo bloquea.
    if (authService.cuidadorActual == null) {
      _mostrarMensaje("Solo un cuidador puede asignar actividades.", Colors.red);
      return;
    }

    final nombre = nombreActividadController.text.trim();
    final descripcion = descripcionActividadController.text.trim();

    if (nombre.isEmpty || _horaSeleccionada == null) {
      _mostrarMensaje("Debe ingresar el nombre y la hora.", Colors.red);
      return;
    }

    if (_imagenSeleccionada == null) {
      _mostrarMensaje("Debe seleccionar una imagen.", Colors.red);
      return;
    }

    if (_diasSeleccionados.isEmpty) {
      _mostrarMensaje("Elige al menos un día de la semana.", Colors.red);
      return;
    }

    // Paciente para el que se está creando la actividad: si el que inició
    // sesión es un Paciente, es él mismo; si es un Cuidador, el que tenga
    // elegido en el selector.
    final pacienteId = authService.pacienteSeleccionado?.pacienteId;

    if (pacienteId == null) {
      _mostrarMensaje("No hay ningún paciente seleccionado.", Colors.red);
      return;
    }

    // La ruta de la imagen queda vacía aquí: el servicio sube el archivo a
    // Storage y completa la ruta real antes de guardar.
    final actividad = Actividad(
      id: '', // provisorio: la base genera el id real al insertar
      nombre: nombre,
      descripcion: descripcion,
      rutaIMG: '',
      hora: _horaSeleccionada!,
      duracion: _duracionSeleccionada,
      diasSemana: _diasSeleccionados,
    );

    setState(() {
      _guardando = true;
    });

    try {
      await actividadService.crearActividad(
        actividad,
        pacienteId,
        imagen: _imagenSeleccionada,
      );

      // Reprograma los avisos sin hacer esperar al usuario
      unawaited(notificationService.sincronizar());

      if (!mounted) return;
      _mostrarMensaje("Actividad creada correctamente.", Colors.green);
      Navigator.pop(context, true);
    } on SolapeActividadException catch (e) {
      // La base de datos bloqueó la actividad porque se cruza con otra
      if (!mounted) return;
      _mostrarMensaje(e.toString(), Colors.orange.shade800);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje("No se pudo guardar la actividad: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
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
            onPressed: _guardando ? null : _guardarActividad,
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

                  const SizedBox(height: 20),

                  // ------------------ Duración de la actividad ------------------
                  DropdownButtonFormField<Duration>(
                    initialValue: _duracionSeleccionada,
                    decoration: const InputDecoration(
                      labelText: "Duración de la actividad",
                      prefixIcon: Icon(Icons.timelapse),
                    ),
                    items: const [
                      DropdownMenuItem(value: Duration(minutes: 5), child: Text("5 minutos")),
                      DropdownMenuItem(value: Duration(minutes: 10), child: Text("10 minutos")),
                      DropdownMenuItem(value: Duration(minutes: 15), child: Text("15 minutos")),
                      DropdownMenuItem(value: Duration(minutes: 30), child: Text("30 minutos")),
                      DropdownMenuItem(value: Duration(minutes: 45), child: Text("45 minutos")),
                      DropdownMenuItem(value: Duration(hours: 1), child: Text("1 hora")),
                    ],
                    onChanged: (nuevaDuracion) {
                      if (nuevaDuracion == null) return;
                      setState(() {
                        _duracionSeleccionada = nuevaDuracion;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // ------------------ NUEVO: días en que se repite ------------------
                  SelectorDias(
                    seleccionados: _diasSeleccionados,
                    onCambio: (nuevos) {
                      setState(() {
                        _diasSeleccionados = nuevos;
                      });
                    },
                  ),

                  const SizedBox(height: 40),

                  // ------------------ Botón principal de guardar ------------------
                  ElevatedButton.icon(
                    onPressed: _guardando ? null : _guardarActividad,
                    icon: _guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_guardando ? "Guardando..." : "Guardar actividad"),
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
