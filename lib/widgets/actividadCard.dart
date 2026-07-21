import 'package:flutter/material.dart';
import 'package:rutina_app/models/actividad.dart';

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
        leading: Image.asset(
          actividad.rutaIMG,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),

        title: Text(actividad.nombre),
        subtitle: Text(
          actividad.hora.format(context),
        ),

        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Ir a la pantalla de detalle
        },
      ),
    );
  }
}