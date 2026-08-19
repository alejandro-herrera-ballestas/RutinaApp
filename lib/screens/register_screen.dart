import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rutina_app/services/auth_service.dart';
import 'package:rutina_app/utils/global.dart';

class registerScreen extends StatefulWidget{
  const registerScreen({super.key});
  @override
  State<registerScreen> createState() => _registerScreenState();  // crear el state de registger
}

class _registerScreenState extends State<registerScreen>  {

  bool ocultarConfirmacion = true;
  bool ocultarContra = true;
  bool cargando = false; // evita doble tap mientras se registra en Supabase

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();    // controladores para guardar los datos
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmContrasenaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController(); // solo aplica si es cuidador

  DateTime? fechaNacimiento;
  RolUsuario rolSeleccionado = RolUsuario.cuidador;

  Future<void> _elegirFechaNacimiento() async {
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (seleccionada != null) {
      setState(() {
        fechaNacimiento = seleccionada;
      });
    }
  }

  Future<void> _registrar() async {
    final nombreCompleto = nombreController.text.trim();
    final email = emailController.text.trim();
    final contrasena = contrasenaController.text;
    final confirmarContra = confirmContrasenaController.text;
    final telefono = telefonoController.text.trim();

    // confirmar que no haya campos vacios
    if (nombreCompleto.isEmpty || email.isEmpty || contrasena.isEmpty || confirmarContra.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debe completar todos los campos."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debe seleccionar su fecha de nacimiento."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (rolSeleccionado == RolUsuario.cuidador && telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debe ingresar un teléfono de contacto."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (contrasena != confirmarContra) {  // confirmar que las contraseñas sean iguales
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las contraseñas no coinciden."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      await authService.registrarUsuario(
        email: email,
        contrasena: contrasena,
        nombre: nombreCompleto,
        fechaNacimiento: fechaNacimiento!,
        rol: rolSeleccionado,
        telefono: rolSeleccionado == RolUsuario.cuidador ? telefono : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(   // mensaje de exito
        const SnackBar(
          content: Text("Usuario registrado correctamente."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No se pudo registrar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2), // color de fondo
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),   // barra
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Rutina App",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 1.2,
          ),
        ),
      ),

      body: Center(   // seccion de registro
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Registro",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
              ),

              SizedBox(
                height: 40,
              ),

              // ROL: cuidador o paciente
              SizedBox(
                width: 300,
                child: SegmentedButton<RolUsuario>(
                  segments: const [
                    ButtonSegment(
                      value: RolUsuario.cuidador,
                      label: Text("Cuidador"),
                      icon: Icon(Icons.shield_outlined),
                    ),
                    ButtonSegment(
                      value: RolUsuario.paciente,
                      label: Text("Paciente"),
                      icon: Icon(Icons.self_improvement),
                    ),
                  ],
                  selected: {rolSeleccionado},
                  onSelectionChanged: (nuevaSeleccion) {
                    setState(() {
                      rolSeleccionado = nuevaSeleccion.first;
                    });
                  },
                ),
              ),

              SizedBox(
                height: 30,
              ),

              SizedBox(   // registrar nombre
                width: 300,
                child: TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre completo",
                    hintText: "Ingrese su nombre completo",
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              SizedBox(     // registrar correo
                width: 300,
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Correo electrónico",
                    hintText: "Ingrese su correo electrónico",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              SizedBox(   // fecha de nacimiento
                width: 300,
                child: InkWell(
                  onTap: _elegirFechaNacimiento,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Fecha de nacimiento",
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Text(
                      fechaNacimiento == null
                          ? "Seleccione una fecha"
                          : DateFormat("d 'de' MMMM 'de' y", 'es_ES').format(fechaNacimiento!),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              // telefono: solo se muestra si el rol es cuidador
              if (rolSeleccionado == RolUsuario.cuidador) ...[
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: telefonoController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Teléfono",
                      hintText: "Ingrese su teléfono de contacto",
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],

              SizedBox(   // registrar contraseña
                width: 300,
                child: TextFormField(
                  controller: contrasenaController,
                  obscureText: ocultarContra,
                  decoration:  InputDecoration(
                    labelText: "Contraseña",
                    hintText: "Ingrese su contraseña",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          ocultarContra = !ocultarContra;
                        });
                      },
                      icon: Icon(
                        ocultarContra
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              SizedBox(   // confirmar contraseña
                width: 300,
                child: TextFormField(
                  controller: confirmContrasenaController,
                  obscureText: ocultarConfirmacion,
                  decoration:  InputDecoration(
                    labelText: "Confirmar Contraseña",
                    hintText: "Confirme su contraseña",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          ocultarConfirmacion = !ocultarConfirmacion;
                        });
                      },
                      icon: Icon(
                        ocultarConfirmacion
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 30,
              ),

              SizedBox(   // boton registro
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: cargando ? null : _registrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6D8B74),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: cargando
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Registrarse",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: cargando
                    ? null
                    : () {
                  Navigator.pop(context, true);
                },
                child: const Text(
                  "¿Ya tienes cuenta? Inicia sesion aqui",
                  style: TextStyle(
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );

  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    contrasenaController.dispose();
    confirmContrasenaController.dispose();
    telefonoController.dispose();
    super.dispose();
  }
}