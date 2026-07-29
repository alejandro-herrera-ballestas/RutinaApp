import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

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
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _mostrarOpciones,
              onLongPress: _verFotoEnGrande, // Opción rápida para ver en grande
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey[300],
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!) as ImageProvider
                    : const AssetImage('assets/Starter pfp.jpeg'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Toca la foto para cambiarla',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}