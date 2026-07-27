import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rutina_app/models/BloqueHorario.dart';
import 'package:rutina_app/screens/detalle_actividad_screen.dart';
import 'package:rutina_app/utils/global.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _fechaSeleccionada = DateTime.now();

  List<BloqueHorario> _bloques = [];
  List<String> _conflictivas = [];

  @override
  void initState() {
    super.initState();

    _fechaSeleccionada = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    _regenerarHorario();
  }

  // ============================================================
  // GENERAR HORARIO
  void _regenerarHorario() {
    final actividades = actividadService.obtenerActividades();

    final conflictos = horarioDelDia.generarDesdeActividades(
      actividades,
      _fechaSeleccionada,
    );

    setState(() {
      _bloques = List.from(horarioDelDia.bloques);
      _conflictivas = conflictos;
    });
  }

  // ============================================================
  // CAMBIAR DÍA
  void _cambiarDia(int cantidad) {
    setState(() {
      _fechaSeleccionada = _fechaSeleccionada.add(
        Duration(days: cantidad),
      );
    });

    _regenerarHorario();
  }

  // ============================================================
  // VOLVER A HOY
  void _irAHoy() {
    setState(() {
      final ahora = DateTime.now();

      _fechaSeleccionada = DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
      );
    });

    _regenerarHorario();
  }

  // ============================================================
  // ABRIR DETALLE DE ACTIVIDAD
  Future<void> _abrirActividad(BloqueHorario bloque) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleActividadScreen(
          actividad: bloque.actividad,
        ),
      ),
    );

    if (resultado == true) {
      _regenerarHorario();
    }
  }

  // ============================================================
  // COMPROBAR SI ES HOY
  bool get _esHoy {
    final ahora = DateTime.now();

    return _fechaSeleccionada.year == ahora.year && _fechaSeleccionada.month == ahora.month && _fechaSeleccionada.day == ahora.day;
  }

  // ============================================================
  // FORMATO DE FECHA
  String _textoFecha() {
    if (_esHoy) {
      return "Hoy";
    }

    return DateFormat(
      "EEEE d 'de' MMMM",
      'es_ES',
    ).format(_fechaSeleccionada);
  }

  // ============================================================
  // FORMATO DE HORA
  String _formatearHora(DateTime hora) {
    return DateFormat('HH:mm').format(hora);
  }

  // ============================================================
  // DURACIÓN
  String _formatearDuracion(Duration duracion) {
    if (duracion.inHours > 0) {
      final horas = duracion.inHours;
      final minutos = duracion.inMinutes.remainder(60);

      if (minutos == 0) {
        return "$horas ${horas == 1 ? 'hora' : 'horas'}";
      }

      return "$horas h ${minutos} min";
    }

    return "${duracion.inMinutes} min";
  }

  // ============================================================
  // ACTIVIDAD ACTUAL
  bool _esActividadActual(BloqueHorario bloque) {
    if (!_esHoy) {
      return false;
    }

    final ahora = DateTime.now();

    return !ahora.isBefore(bloque.horaInicio) &&
        ahora.isBefore(bloque.horaFin);
  }

  // ============================================================
  // WIDGET DEL ENCABEZADO
  Widget _buildSelectorFecha() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _cambiarDia(-1);
            },
            icon: const Icon(Icons.chevron_left),
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  _textoFecha(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  DateFormat(
                    "d 'de' MMMM 'de' yyyy",
                    'es_ES',
                  ).format(_fechaSeleccionada),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              _cambiarDia(1);
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTÓN HOY
  Widget _buildBotonHoy() {
    if (_esHoy) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: TextButton.icon(
          onPressed: _irAHoy,
          icon: const Icon(Icons.today),
          label: const Text("Volver a hoy"),
        ),
      ),
    );
  }

  // ============================================================
  // CONFLICTOS

  Widget _buildConflictos() {
    if (_conflictivas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.orange.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange.shade800,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Conflicto de horario",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "No se pudieron ubicar: "
                      "${_conflictivas.join(', ')}",
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ENCABEZADO DE ACTIVIDADES
  Widget _buildTituloActividades() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24,
        bottom: 12,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Actividades",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (_bloques.isNotEmpty)
            Text(
              "${_bloques.length} "
                  "${_bloques.length == 1 ? 'actividad' : 'actividades'}",
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TARJETA DE ACTIVIDAD
  Widget _buildBloque(BloqueHorario bloque) {
    final actividad = bloque.actividad;

    final bool actual = _esActividadActual(bloque);
    final bool completada = actividad.completada;

    return GestureDetector(
      onTap: () {
        _abrirActividad(bloque);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: actual
                ? Colors.blue.shade300
                : Colors.grey.shade200,
            width: actual ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HORA
            SizedBox(
              width: 58,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatearHora(bloque.horaInicio),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: actual
                          ? Colors.blue.shade700
                          : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    _formatearHora(bloque.horaFin),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ==================================================
            // SEPARADOR
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                color: completada
                    ? Colors.green
                    : actual
                    ? Colors.blue
                    : Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(width: 14),

            // ==================================================
            // INFORMACIÓN
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          actividad.nombre,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            decoration: completada
                                ? TextDecoration.lineThrough
                                : null,
                            color: completada
                                ? Colors.black45
                                : Colors.black87,
                          ),
                        ),
                      ),

                      if (completada)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 21,
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  if (actividad.descripcion.isNotEmpty)
                    Text(
                      actividad.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.timelapse,
                        size: 15,
                        color: Colors.black45,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        _formatearDuracion(
                          actividad.duracion,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),

                      if (actual) ...[
                        const SizedBox(width: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Ahora",
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SIN ACTIVIDADES
  Widget _buildSinActividades() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 70,
                color: Colors.grey.shade400,
              ),

              const SizedBox(height: 18),

              const Text(
                "No hay actividades",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "No tienes actividades programadas "
                    "para este día.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Calendario",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        actions: [
          IconButton(
            tooltip: "Actualizar",
            onPressed: _regenerarHorario,
            icon: const Icon(
              Icons.refresh,
              color: Colors.black87,
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Calendario",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de fecha
              _buildSelectorFecha(),

              // Botón volver a hoy
              _buildBotonHoy(),

              // Aviso de conflictos
              _buildConflictos(),

              // Título
              _buildTituloActividades(),

              // Lista
              if (_bloques.isEmpty)
                _buildSinActividades()
              else
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _bloques.length,
                    itemBuilder: (context, index) {
                      return _buildBloque(
                        _bloques[index],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}