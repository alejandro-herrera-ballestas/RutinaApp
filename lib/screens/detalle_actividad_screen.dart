import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rutina_app/models/actividad.dart';
import 'dart:io';
import 'package:rutina_app/utils/global.dart';

class DetalleActividadScreen extends StatefulWidget {
  final Actividad actividad;

  const DetalleActividadScreen({
    super.key,
    required this.actividad,
  });

  @override
  State<DetalleActividadScreen> createState() => _DetalleActividadScreenState();
}

class _DetalleActividadScreenState extends State<DetalleActividadScreen> {

  final TextEditingController nombreActividadController = TextEditingController();
  final TextEditingController descripcionActividadController = TextEditingController();
  final TextEditingController horaActividadController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  TimeOfDay? _horaSeleccionada;
  File? _imagenSeleccionada;
  Duration _duracionSeleccionada = const Duration(minutes: 15);

  @override
  void initState() {
    super.initState();
    // Precargamos los datos actuales de la actividad para poder editarlos
    nombreActividadController.text = widget.actividad.nombre;
    descripcionActividadController.text = widget.actividad.descripcion;

    _horaSeleccionada = widget.actividad.hora;
    final horas = widget.actividad.hora.hour.toString().padLeft(2, '0');
    final minutos = widget.actividad.hora.minute.toString().padLeft(2, '0');
    horaActividadController.text = '$horas:$minutos';

    _duracionSeleccionada = widget.actividad.duracion; 

    if (widget.actividad.rutaIMG.isNotEmpty) {
      _imagenSeleccionada = File(widget.actividad.rutaIMG);
    }
  }

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

  // ============================ Eliminar actividad ============================
  Future<void> _confirmarEliminar() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar actividad"),
          content: Text(
            "¿Seguro que deseas eliminar \"${widget.actividad.nombre}\"? Esta acción no se puede deshacer.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return; // el usuario canceló o cerró el diálogo

    final bool eliminado = actividadService.eliminarActividad(widget.actividad.id);

    if (!eliminado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo eliminar la actividad."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.pop(context, true);
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

  // ============================ Guardar cambios ============================
  void _guardarCambios() {
    final nombre = nombreActividadController.text.trim();
    final descripcion = descripcionActividadController.text.trim();

    if (nombre.isEmpty || _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debe ingresar el nombre y la hora."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool editado = actividadService.editarActividad(
      widget.actividad.id,
      nombre: nombre,
      descripcion: descripcion,
      rutaIMG: _imagenSeleccionada?.path,
      hora: _horaSeleccionada,
      duracion: _duracionSeleccionada,
    );

    if (!editado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo actualizar la actividad."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Actividad actualizada correctamente."),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  // Widget auxiliar: muestra la imagen elegida, o el placeholder si no hay ninguna
  Widget _buildImagenPreview() {
    if (_imagenSeleccionada != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _imagenSeleccionada!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            // Si el archivo ya no existe en el dispositivo, mostramos el placeholder
            return _buildPlaceholder();
          },
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 45, color: Colors.grey),
        SizedBox(height: 10),
        Text("Agregar imagen", style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text(
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
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Eliminar actividad',
            onPressed: _confirmarEliminar,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Guardar cambios',
            onPressed: _guardarCambios,
          ),
        ],
      ),

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
                  // ------------------ Imagen de la actividad ------------------
                  GestureDetector(
                    onTap: _seleccionarImagen,
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: _buildImagenPreview(),
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
                    readOnly: true,
                    onTap: _seleccionarHora,
                    decoration: const InputDecoration(
                      labelText: "Ingrese la hora de la actividad",
                      hintText: "Ej: 8:00",
                      suffixIcon: Icon(Icons.access_time_filled),
                    ),
                  ),

                  const SizedBox(height: 40),

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

                  // ------------------ Botón principal de guardar ------------------
                  ElevatedButton.icon(
                    onPressed: _guardarCambios,
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar cambios"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  //--------------- Boton completar actividad-----------------------
                  ElevatedButton.icon(
                    onPressed: widget.actividad.completada
                        ? null
                        : () {
                      final completada = actividadService.completarActividad(widget.actividad.id,
                      );
                      if (completada) {
                        setState(() {});
                      }
                    },
                    icon: Icon(
                      widget.actividad.completada
                          ? Icons.check_circle
                          : Icons.check_sharp,
                    ),
                    label: Text(
                      widget.actividad.completada
                          ? "Actividad completada"
                          : "Completar Actividad",
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                //--------------- Botón eliminar actividad -----------------------
                  OutlinedButton.icon(
                    onPressed: _confirmarEliminar,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      "Eliminar actividad",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
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