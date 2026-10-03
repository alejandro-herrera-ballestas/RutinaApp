import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rutina_app/utils/global.dart';

// Pantalla donde un Cuidador escribe el CÓDIGO que le dio su paciente
// (el paciente lo genera en su Perfil). Así el paciente es quien acepta
// el vínculo (tabla cuidador_paciente).
class VincularPacienteScreen extends StatefulWidget {
  const VincularPacienteScreen({super.key});

  @override
  State<VincularPacienteScreen> createState() => _VincularPacienteScreenState();
}

class _VincularPacienteScreenState extends State<VincularPacienteScreen> {
  final TextEditingController codigoController = TextEditingController();

  bool vinculando = false;

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  Future<void> _vincular() async {
    if (vinculando) return;

    final codigo = codigoController.text.trim().toUpperCase();

    if (codigo.length != 6) {
      _mostrarMensaje("El código tiene 6 caracteres.", Colors.red);
      return;
    }

    // Solo un cuidador puede usar un código
    final cuidador = authService.cuidadorActual;
    if (cuidador == null) {
      _mostrarMensaje(
        "Debes iniciar sesión como cuidador para vincular un paciente.",
        Colors.red,
      );
      return;
    }

    setState(() {
      vinculando = true;
    });

    try {
      final resultado =
          await authService.cuidadorPacienteService.vincularConCodigo(codigo);

      // null = código inválido, vencido o ya usado
      if (resultado == null) {
        if (!mounted) return;
        _mostrarMensaje(
          "Código inválido, vencido o ya usado. Pídele al paciente uno nuevo.",
          Colors.red,
        );
        return;
      }

      final String nombrePaciente = resultado['nombre'].toString();

      // recargamos la lista del cuidador para que el nuevo paciente
      // quede disponible en el selector de Inicio/Calendario de inmediato.
      await authService.recargarPacientesDelCuidador();

      // Ahora también debe recibir los avisos del paciente nuevo
      unawaited(notificationService.sincronizar());

      if (!mounted) return;
      _mostrarMensaje("Vinculado con $nombrePaciente correctamente.", Colors.green);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(
        e.toString().replaceFirst('Exception: ', ''),
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          vinculando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Vincular paciente",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link, size: 80),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Pídele a tu paciente que abra su Perfil y toque "
                  "\"Generar código para un cuidador\". Escribe aquí "
                  "el código de 6 caracteres que le aparece.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 300,
                child: TextFormField(
                  controller: codigoController,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  ],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Código del paciente",
                    hintText: "K7M2QX",
                    counterText: "",
                  ),
                  onFieldSubmitted: (_) => _vincular(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: vinculando ? null : _vincular,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D8B74),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: vinculando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Vincular", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    codigoController.dispose();
    super.dispose();
  }
}
