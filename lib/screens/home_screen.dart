import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rutina_app/screens/detalle_actividad_screen.dart';
import 'package:rutina_app/widgets/actividadCard.dart';
import 'package:rutina_app/utils/global.dart';
import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/services/progreso_actividad_service.dart';
import 'add_activity_screen.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final ProgresoActividadService progresoService =
ProgresoActividadService();

List<Actividad> actividades = [];

bool cargando = true;
String? error;

@override
void initState() {
super.initState();
_cargarDatos();
}

Future<void> _cargarDatos() async {
setState(() {
cargando = true;
error = null;
});

try {
final paciente = authService.pacienteSeleccionado;

// Si todavía no hay un paciente seleccionado,
// no podemos cargar sus actividades.
if (paciente == null) {
setState(() {
actividades = [];
cargando = false;
});
return;
}

// 1. Obtener las actividades del paciente desde Supabase.
final actividadesPaciente =
await actividadService.obtenerActividadesPaciente(
paciente.pacienteId,
);

// 2. Obtener el progreso correspondiente a HOY.
final ids = actividadesPaciente.map((a) => a.id).toList();

final progresoHoy = await progresoService.obtenerProgresoDelDia(
ids,
DateTime.now(),
);

// 3. Aplicar el progreso de hoy a cada actividad.
for (final actividad in actividadesPaciente) {
final progreso = progresoHoy[actividad.id];

actividad.completada = progreso?.completada ?? false;
actividad.fechaCompletada =
progreso?.horaCompletada;
}

if (!mounted) return;

setState(() {
actividades = actividadesPaciente;
cargando = false;
});
} catch (e) {
if (!mounted) return;

setState(() {
error = e.toString();
cargando = false;
});
}
}

Future<void> _abrirDetalle(Actividad actividad) async {
final actualizado = await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => DetalleActividadScreen(
actividad: actividad,
),
),
);

// Si el detalle modificó algo, volvemos a consultar Supabase.
if (actualizado == true) {
await _cargarDatos();
}
}

@override
Widget build(BuildContext context) {
final String fechaHoy =
DateFormat("d 'de' MMMM", 'es_ES').format(DateTime.now());

final paciente = authService.pacienteSeleccionado;

return Scaffold(
backgroundColor: const Color(0xFFF8F5F2),

appBar: AppBar(
backgroundColor: const Color(0xFFFFFBF5),
elevation: 0,
centerTitle: true,

title: const Text(
"RutinaApp",
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: Colors.black87,
),
),

actions: [
IconButton(
icon: const Icon(Icons.notifications_none),
onPressed: () {},
),
],
),

body: Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

const Text(
"Hoy",
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 5),

Text(
fechaHoy,
style: const TextStyle(
fontSize: 18,
color: Colors.black54,
),
),

// Mostramos el paciente que está activo.
if (paciente != null) ...[
const SizedBox(height: 8),

Text(
paciente.nombre,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
color: Colors.black54,
),
),
],

const SizedBox(height: 20),

Expanded(
child: _construirContenido(),
),
],
),
),

floatingActionButton: FloatingActionButton(
onPressed: () async {
final resultado = await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const AddActivityScreen(),
),
);

if (resultado == true) {
await _cargarDatos();
}
},
child: const Icon(Icons.add_task),
),
);
}

Widget _construirContenido() {
if (cargando) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (error != null) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.error_outline,
size: 50,
color: Colors.redAccent,
),

const SizedBox(height: 12),

const Text(
'No se pudieron cargar las actividades.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
),
),

const SizedBox(height: 8),

Text(
error!,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 12,
color: Colors.black54,
),
),

const SizedBox(height: 16),

ElevatedButton(
onPressed: _cargarDatos,
child: const Text('Reintentar'),
),
],
),
);
}

if (authService.pacienteSeleccionado == null) {
return const Center(
child: Text(
'No hay ningún paciente seleccionado.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 16,
color: Colors.black54,
),
),
);
}

if (actividades.isEmpty) {
return const Center(
child: Text(
'No hay actividades para este paciente.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 16,
color: Colors.black54,
),
),
);
}

return RefreshIndicator(
onRefresh: _cargarDatos,

child: ListView.builder(
itemCount: actividades.length,

itemBuilder: (context, index) {
final actividad = actividades[index];

return ActividadCard(
actividad: actividad,

onTap: () => _abrirDetalle(actividad),
);
},
),
);
}
}
