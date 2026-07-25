import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rutina_app/models/actividad.dart';

class ActividadCard extends StatelessWidget {
  final Actividad actividad;
  final VoidCallback onTap;

  const ActividadCard({
    super.key,
    required this.actividad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.file(
          File(actividad.rutaIMG),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
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