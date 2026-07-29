import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rutina_app/models/BloqueHorario.dart';
import 'package:rutina_app/utils/global.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  List<String> _conflictivas = [];

  DateTime _fechaSeleccionada = DateTime.now();

  // Altura aproximada de cada hora en el calendario.
  static const double _altoPorHora = 80;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _regenerarHorario();
    });
  }
  // GENERAR HORARIO
  void _regenerarHorario() {
    final actividades = actividadService.obtenerActividades();

    final conflictos = horarioDelDia.generarDesdeActividades(
      actividades,
      _fechaSeleccionada,
    );

    if (!mounted) return;

    setState(() {
      _conflictivas = conflictos;
    });

    if (conflictos.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "No se pudieron ubicar: ${conflictos.join(', ')} "
                  "(conflicto de horario)",
            ),
            backgroundColor: Colors.orange,
          ),
        );
      });
    }
  }

  // CAMBIAR FECHA
  Future<void> _seleccionarFecha() async {
    final DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (nuevaFecha == null) return;

    setState(() {
      _fechaSeleccionada = nuevaFecha;
    });

    _regenerarHorario();
  }

  // FORMATEAR FECHA
  String _fechaFormateada() {
    final String fecha = DateFormat(
      "EEEE d 'de' MMMM",
      'es_ES',
    ).format(_fechaSeleccionada);

    return fecha[0].toUpperCase() + fecha.substring(1);
  }

  // VERIFICAR SI ES HOY
  bool _esHoy() {
    final ahora = DateTime.now();

    return ahora.year == _fechaSeleccionada.year &&
        ahora.month == _fechaSeleccionada.month &&
        ahora.day == _fechaSeleccionada.day;
  }

  // VOLVER A HOY
  void _irAHoy() {
    setState(() {
      _fechaSeleccionada = DateTime.now();
    });

    _regenerarHorario();
  }

  // CONSTRUIR TARJETA DE ACTIVIDAD
  Widget _crearTarjetaActividad(
      BuildContext context,
      BloqueHorario bloque,
      ) {
    final actividad = bloque.actividad;

    final String horaInicio = DateFormat(
      'HH:mm',
    ).format(bloque.horaInicio);

    final String horaFin = DateFormat(
      'HH:mm',
    ).format(bloque.horaFin);

    final int minutos = bloque.calcularDuracion().inMinutes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: actividad.completada
            ? Colors.green.shade50
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: actividad.completada
              ? Colors.green.shade200
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Indicador de actividad
          Container(
            width: 5,
            height: 48,
            decoration: BoxDecoration(
              color: actividad.completada
                  ? Colors.green
                  : Colors.deepPurpleAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(width: 12),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actividad.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: actividad.completada
                        ? Colors.green.shade800
                        : Colors.black87,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$horaInicio - $horaFin · $minutos min',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Estado
          if (actividad.completada)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 22,
            )
          else
            const Icon(
              Icons.chevron_right,
              color: Colors.black45,
              size: 22,
            ),
        ],
      ),
    );
  }
  // CONSTRUIR HORARIO
  Widget _crearHorario() {
    final List<BloqueHorario> bloques = [
      ...horarioDelDia.bloques,
    ];

    bloques.sort(
          (a, b) => a.horaInicio.compareTo(b.horaInicio),
    );

    const int horaInicial = 6;
    const int horaFinal = 23;

    final double alturaTotal =
        ((horaFinal - horaInicial) * _altoPorHora) + 40;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 30,
        bottom: 60,
        left: 4,
        right: 4,
      ),
      child: SizedBox(
        height: alturaTotal,
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            // Línea vertical
            Positioned(
              left: 57,
              top: 0,
              bottom: 20,
              child: Container(
                width: 1,
                color: Colors.grey.shade300,
              ),
            ),

            // Horas
            for (int hora = horaInicial;
            hora <= horaFinal;
            hora++)
              Positioned(
                top: (hora - horaInicial) * _altoPorHora - 7,
                left: 0,
                width: 48,
                child: Text(
                  '${hora.toString().padLeft(2, '0')}:00',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

            // Líneas horizontales
            for (int hora = horaInicial;
            hora <= horaFinal;
            hora++)
              Positioned(
                top: (hora - horaInicial) * _altoPorHora,
                left: 65,
                right: 0,
                child: Container(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
              ),

            // Actividades
            for (final bloque in bloques)
              _crearPosicionActividad(
                bloque,
                horaInicial,
              ),

            // Línea de hora actual
            if (_esHoy())
              _crearLineaHoraActual(horaInicial),
          ],
        ),
      ),
    );
  }
  // POSICIÓN DE UNA ACTIVIDAD
  Widget _crearPosicionActividad(
      BloqueHorario bloque,
      int horaInicial,
      ) {
    final double minutosDesdeInicio =
        bloque.horaInicio.hour * 60 +
            bloque.horaInicio.minute -
            horaInicial * 60;

    final double duracionMinutos =
    bloque.calcularDuracion().inMinutes.toDouble();

    final double top =
        (minutosDesdeInicio / 60) * _altoPorHora;

    // Altura mínima para que siempre quepan
    // nombre + horario.
    final double altura = ((duracionMinutos / 60) * _altoPorHora)
        .clamp(62.0, 150.0);

    return Positioned(
      top: top,
      left: 70,
      right: 4,
      height: altura,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 6,
        ),
        child: _crearTarjetaActividad(
          context,
          bloque,
        ),
      ),
    );
  }
  // LÍNEA DE HORA ACTUAL
  Widget _crearLineaHoraActual(int horaInicial) {
    final ahora = DateTime.now();

    final double minutosDesdeInicio =
        ahora.hour * 60 +
            ahora.minute -
            horaInicial * 60;

    if (minutosDesdeInicio < 0 ||
        minutosDesdeInicio > (23 - horaInicial) * 60) {
      return const SizedBox.shrink();
    }

    final double top =
        (minutosDesdeInicio / 60) * _altoPorHora;

    return Positioned(
      top: top,
      left: 53,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Container(
              height: 1.5,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }


  // BUILD
  @override
  Widget build(BuildContext context) {
    final int cantidadActividades =
        horarioDelDia.bloques.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      // APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Calendario",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        actions: [
          // Botón para volver a hoy
          if (!_esHoy())
            IconButton(
              tooltip: 'Ir a hoy',
              icon: const Icon(Icons.today),
              onPressed: _irAHoy,
            ),

          // Selector de fecha
          IconButton(
            tooltip: 'Seleccionar fecha',
            icon: const Icon(Icons.calendar_month),
            onPressed: _seleccionarFecha,
          ),
        ],
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;

          Navigator.pop(context);
        },
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
      // BODY
      body: SafeArea(
        child: Column(
          children: [
            // ENCABEZADO
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Actividades",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          _fechaFormateada(),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    cantidadActividades == 1
                        ? "1 actividad"
                        : "$cantidadActividades actividades",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // CONFLICTOS
            if (_conflictivas.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  10,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Hay actividades con conflictos de horario.",
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // HORARIO
            Expanded(
              child: horarioDelDia.bloques.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    "No hay actividades programadas para este día.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
                  : _crearHorario(),
            ),
          ],
        ),
      ),
    );
  }
}