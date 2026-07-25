import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/screens/detalle_actividad_screen.dart';

class ActividadCard extends StatelessWidget {

  final Actividad actividad;

  const ActividadCard({
    super.key,
    required this.actividad,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.file(
            File(actividad.rutaIMG)
        ),

        title: Text(actividad.nombre),
        subtitle: Text(
          actividad.hora.format(context),
        ),

        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => DetalleActividadScreen(
                  actividad: actividad,
              ),
              ),
          );
        },
      ),
    );
  }
}