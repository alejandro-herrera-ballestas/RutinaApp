// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/services/storage_service.dart';
import 'package:rutina_app/widgets/imagen_storage.dart';

class actividadCard extends StatelessWidget {
  final Actividad actividad;
  final VoidCallback onTap;

  const actividadCard({
    super.key,
    required this.actividad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        // La imagen ya no es un archivo local: viene del bucket 'actividades'
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ImagenStorage(
            bucket: StorageService.bucketActividades,
            ruta: actividad.rutaIMG,
            width: 60,
            height: 60,
          ),
        ),

        title: Text(actividad.nombre),

        subtitle: Text(
          actividad.hora.format(context),
        ),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: onTap,
      ),
    );
  }
}
