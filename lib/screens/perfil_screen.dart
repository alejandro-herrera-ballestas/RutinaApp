import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rutina_app/screens/login_screen.dart';
import 'package:rutina_app/screens/vincular_paciente_screen.dart';
import 'package:rutina_app/utils/global.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final usuario = authService.usuarioActual;
  final String correo = supabase.auth.currentUser?.email ?? "";
  final String rol = authService.cuidadorActual != null ? "Cuidador" : "Paciente";
  late Future<List<dynamic>> _vinculadosFuture;

  @override
  void initState() {
    super.initState();
    _vinculadosFuture = _obtenerVinculados();
  }

  Future<List<dynamic>> _obtenerVinculados() async {
    if (authService.cuidadorActual != null) {
      return await authService.cuidadorPacienteService
          .obtenerPacientesDeCuidador(authService.cuidadorActual!.cuidadorId);
    } else if (authService.pacienteActual != null) {
      return await authService.cuidadorPacienteService
          .obtenerCuidadoresDePaciente(authService.pacienteActual!.pacienteId);
    }
    return [];
  }

  // Función para abrir la cámara o la galería
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Función para ver la foto en grande
  void _verFotoEnGrande() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: InteractiveViewer(
          panEnabled: true, // Permite mover la imagen
          minScale: 0.5,
          maxScale: 4,
          child: _imageFile != null
              ? Image.file(_imageFile!, fit: BoxFit.contain)
              : Image.asset('assets/Starter pfp.jpeg', fit: BoxFit.contain),
        ),
      ),
    );
  }

  // tarjeta de estadisticas
  Widget tarjetaEstadistica(
      String titulo,
      String valor,
      IconData icono,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icono),
        title: Text(titulo),
        trailing: Text(
          valor,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Menú de opciones al tocar la foto
  void _mostrarOpciones() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.fullscreen),
                title: const Text('Ver foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _verFotoEnGrande();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de la biblioteca'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final total = actividadService.cantidadActividades();
    final completadas = actividadService.actividadesCompletadas();
    final pendientes = total - completadas;

    final porcentaje = total == 0
        ? 0
        : ((completadas / total) * 100).round();

    return Scaffold(
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              GestureDetector(
                onTap: _mostrarOpciones,
                onLongPress: _verFotoEnGrande,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : const AssetImage('assets/Starter pfp.jpeg')
                  as ImageProvider,
                ),
              ),

              const SizedBox(width: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    usuario?.nombre ?? "",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    correo.isNotEmpty ? "$correo · $rol" : rol,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(
                    height: 50,
                  ),

                  // estadisticas
                  const Text("Estadisticas"),
                  tarjetaEstadistica("Actividades creadas", "$total", Icons.list_alt),
                  tarjetaEstadistica("Completadas", "$completadas", Icons.check_circle),
                  tarjetaEstadistica("Pendientes", "$pendientes", Icons.schedule),
                  tarjetaEstadistica("Progreso", "$porcentaje%", Icons.show_chart),

                  LinearProgressIndicator(
                    value: total == 0 ? 0 : completadas / total,
                  ),

                  const SizedBox(height: 30),

                  Text(
                    authService.cuidadorActual != null ? "Pacientes asignados" : "Cuidadores vinculados",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  FutureBuilder<List<dynamic>>(
                    future: _vinculadosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      final lista = snapshot.data ?? [];
                      if (lista.isEmpty) {
                        return const Text("No hay personas vinculadas aún.");
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: lista.map((item) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(item.nombre),
                            subtitle: Text(item.email),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.settings),
                    label: const Text("Configuración"),
                  ),

                  SizedBox(height: 20),

                  // Solo el cuidador necesita vincular a su paciente.
                  if (authService.cuidadorActual != null)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final resultado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VincularPacienteScreen(),
                          ),
                        );
                        if (resultado == true) {
                          setState(() {
                            _vinculadosFuture = _obtenerVinculados();
                          });
                        }
                      },
                      icon: const Icon(Icons.person_search),
                      label: const Text("Vincular paciente"),
                    ),

                  SizedBox(height: 20),

                  ElevatedButton.icon(onPressed: () async {
                    await authService.cerrarSesion();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                    );
                  },
                    label: Text("Cerrar Sesion"),
                    icon: Icon(Icons.logout),
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }
}