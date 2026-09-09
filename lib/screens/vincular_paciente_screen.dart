import 'package:flutter/material.dart';
import 'package:rutina_app/services/Cuidador_Paciente.dart';
import 'package:rutina_app/utils/global.dart';

class VincularPacienteScreen extends StatefulWidget {
  const VincularPacienteScreen({super.key});

  @override
  State<VincularPacienteScreen> createState() => _VincularPacienteScreenState();
}

class _VincularPacienteScreenState extends State<VincularPacienteScreen>  {
  final TextEditingController emailController = TextEditingController();
  final CuidadorPaciente CuidadorPacienteService = CuidadorPaciente();

  bool buscando = false;

  future <void> _buscarYVincular() async  {
    final email = emailController.text.trim();
  }

  if (email.isEmpty)  {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingresa el correo del paciente: "), backgroundColor: Colors.red,));
    return;
  }

  final cuidador = authService.cuidadorActual;
  if (cuidador == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:
  Text("Debes iniciar sesion como cuidador para vincular un paciente."),
  backgroundColor: Colors.red,),);
  }

  setState((){
    buscando = true;
  });

  try {
    final encontrado = await cuidadorPacienteService.buscarPacientePorEmail(email);

    if (encontrado == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  content: Text("No se encontro ningun paciente registrado con ese correo."),
  backgroundColor: Colors.red,), );
      return;
  }
    final String pacienteId = encontrado['paciente_id'];
    final String nombrePaciente = encontrado['nombre'];

  await cuidadorPacienteService.asignarPaciente(pacienteId, cuidador.cuidadorId);

  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: Text("Vinculado con $nombrePaciente correctamente."),
  backgroundColor: Colors.green,
  ),
  );
  Navigator.pop(context, true);
  } catch (e) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: Text("No se pudo vincular: $e"),
  backgroundColor: Colors.red,
  ),
  );
  } finally {
  if (mounted) {
  setState(() {
  buscando = false;
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
            const Icon(Icons.person_search, size: 80),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Ingresa el correo con el que tu paciente se registró en la app.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 300,
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo del paciente",
                  hintText: "Ingrese el correo electrónico",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: buscando ? null : _buscarYVincular,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D8B74),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: buscando
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Text("Buscar y vincular", style: TextStyle(fontSize: 18)),
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
  emailController.dispose();
  super.dispose();
}
}
  }
}