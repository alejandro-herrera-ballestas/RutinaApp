import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/models/BloqueHorario.dart';
import 'package:rutina_app/screens/detalle_actividad_screen.dart';
import 'package:rutina_app/utils/global.dart';

// Rango de horas visible en el timeline (calculado dinámicamente
class _RangoHoras {
  final DateTime inicio;
  final DateTime fin;
  _RangoHoras(this.inicio, this.fin);
}

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> with RouteAware {
  static const double _pixelesPorMinuto = 1.2;
  static const double _anchoColumnaHora = 56;

  DateTime _fechaSeleccionada = DateTime.now();
  List<BloqueHorario> _bloques = [];
  Set<BloqueHorario> _bloquesConConflicto = {};

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _fechaSeleccionada = DateTime(ahora.year, ahora.month, ahora.day);
    _regenerarHorario();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _regenerarHorario();
  }

  // GENERAR HORARIO Y DETECTAR CONFLICTOS
  void _regenerarHorario() {
    final List<Actividad> actividades = actividadService.obtenerActividades();

    horarioDelDia.generarDesdeActividades(actividades, _fechaSeleccionada);

    final List<BloqueHorario> bloquesCompletos = actividades.map((a) {
      final inicio = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        a.hora.hour,
        a.hora.minute,
      );
      return BloqueHorario(
        horaInicio: inicio,
        horaFin: inicio.add(a.duracion),
        actividad: a,
      );
    }).toList()
      ..sort((x, y) => x.horaInicio.compareTo(y.horaInicio));

    setState(() {
      _bloques = bloquesCompletos;
      _bloquesConConflicto = _detectarConflictos(bloquesCompletos);
    });
  }

  Set<BloqueHorario> _detectarConflictos(List<BloqueHorario> bloques) {
    final conflictivos = <BloqueHorario>{};
    for (int i = 0; i < bloques.length; i++) {
      for (int j = i + 1; j < bloques.length; j++) {
        final a = bloques[i];
        final b = bloques[j];
        final seSolapan =
            a.horaInicio.isBefore(b.horaFin) && b.horaInicio.isBefore(a.horaFin);
        if (seSolapan) {
          conflictivos.add(a);
          conflictivos.add(b);
        }
      }
    }
    return conflictivos;
  }

  // NAVEGACIÓN DE FECHA
  void _cambiarDia(int cantidad) {
    setState(() {
      _fechaSeleccionada = _fechaSeleccionada.add(Duration(days: cantidad));
    });
    _regenerarHorario();
  }

  void _irAHoy() {
    final ahora = DateTime.now();
    setState(() {
      _fechaSeleccionada = DateTime(ahora.year, ahora.month, ahora.day);
    });
    _regenerarHorario();
  }

  Future<void> _abrirDatePicker() async {
    final elegido = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );
    if (elegido == null) return;
    setState(() {
      _fechaSeleccionada = DateTime(elegido.year, elegido.month, elegido.day);
    });
    _regenerarHorario();
  }

  bool get _esHoy {
    final ahora = DateTime.now();
    return _fechaSeleccionada.year == ahora.year &&
        _fechaSeleccionada.month == ahora.month &&
        _fechaSeleccionada.day == ahora.day;
  }

  // ABRIR DETALLE DE ACTIVIDAD
  Future<void> _abrirActividad(BloqueHorario bloque) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleActividadScreen(actividad: bloque.actividad),
      ),
    );
    if (resultado == true) {
      _regenerarHorario();
    }
  }

  bool _esActividadActual(BloqueHorario bloque) {
    if (!_esHoy) return false;
    final ahora = DateTime.now();
    return !ahora.isBefore(bloque.horaInicio) && ahora.isBefore(bloque.horaFin);
  }

  // RANGO DE HORAS DEL TIMELINE (dinámico, con piso/techo por defecto)
  _RangoHoras _calcularRango() {
    final base = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
    );
    DateTime piso = base.add(const Duration(hours: 6));
    DateTime techo = base.add(const Duration(hours: 23));

    if (_bloques.isNotEmpty) {
      final minInicio =
      _bloques.map((b) => b.horaInicio).reduce((a, b) => a.isBefore(b) ? a : b);
      final maxFin = _bloques.map((b) => b.horaFin).reduce((a, b) => a.isAfter(b) ? a : b);

      final inicioHora =
      DateTime(minInicio.year, minInicio.month, minInicio.day, minInicio.hour);
      if (inicioHora.isBefore(piso)) piso = inicioHora;

      DateTime finHora = DateTime(maxFin.year, maxFin.month, maxFin.day, maxFin.hour);
      if (maxFin.minute > 0) finHora = finHora.add(const Duration(hours: 1));
      if (finHora.isAfter(techo)) techo = finHora;
    }

    return _RangoHoras(piso, techo);
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
          "Calendario",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          // BOTON REGENERAR HORARIO
          IconButton(
            tooltip: "Actualizar",
            onPressed: _regenerarHorario,
            icon: const Icon(Icons.refresh, color: Colors.black87),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Calendario"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SelectorFechaHeader(
                fecha: _fechaSeleccionada,
                esHoy: _esHoy,
                onAnterior: () => _cambiarDia(-1),
                onSiguiente: () => _cambiarDia(1),
                onVolverAHoy: _irAHoy,
                onTocarFecha: _abrirDatePicker,
              ),

              if (_bloquesConConflicto.isNotEmpty)
                _ConflictoBanner(cantidad: _bloquesConConflicto.length),

              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Actividades",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    if (_bloques.isNotEmpty)
                      Text(
                        "${_bloques.length} ${_bloques.length == 1 ? 'actividad' : 'actividades'}",
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                  ],
                ),
              ),

              if (_bloques.isEmpty)
                const _SinActividades()
              else
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _TimelineDia(
                      bloques: _bloques,
                      conflictivos: _bloquesConConflicto,
                      rango: _calcularRango(),
                      pixelesPorMinuto: _pixelesPorMinuto,
                      anchoColumnaHora: _anchoColumnaHora,
                      esActividadActual: _esActividadActual,
                      onTapBloque: _abrirActividad,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ENCABEZADO: selector de fecha con flechas + date picker
class _SelectorFechaHeader extends StatelessWidget {
  final DateTime fecha;
  final bool esHoy;
  final VoidCallback onAnterior;
  final VoidCallback onSiguiente;
  final VoidCallback onVolverAHoy;
  final VoidCallback onTocarFecha;

  const _SelectorFechaHeader({
    required this.fecha,
    required this.esHoy,
    required this.onAnterior,
    required this.onSiguiente,
    required this.onVolverAHoy,
    required this.onTocarFecha,
  });

  String get _textoFecha {
    if (esHoy) return "Hoy";
    return DateFormat("EEEE d 'de' MMMM", 'es_ES').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              IconButton(onPressed: onAnterior, icon: const Icon(Icons.chevron_left)),
              Expanded(
                child: GestureDetector(
                  onTap: onTocarFecha, // abre el date picker al tocar la fecha
                  child: Column(
                    children: [
                      Text(
                        _textoFecha,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat("d 'de' MMMM 'de' yyyy", 'es_ES').format(fecha),
                        style: const TextStyle(fontSize: 13,
                            color: Colors.black54
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(onPressed: onSiguiente, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ),
        if (!esHoy)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextButton.icon(
              onPressed: onVolverAHoy,
              icon: const Icon(Icons.today),
              label: const Text("Volver a hoy"),
            ),
          ),
      ],
    );
  }
}

// BANNER: aviso de conflictos de horario
class _ConflictoBanner extends StatelessWidget {
  final int cantidad;
  const _ConflictoBanner({required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$cantidad ${cantidad == 1 ? 'actividad tiene' : 'actividades tienen'} conflicto de horario. "
                  "Revisa las marcadas en rojo.",
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDia extends StatelessWidget {
  final List<BloqueHorario> bloques;
  final Set<BloqueHorario> conflictivos;
  final _RangoHoras rango;
  final double pixelesPorMinuto;
  final double anchoColumnaHora;
  final bool Function(BloqueHorario) esActividadActual;
  final void Function(BloqueHorario) onTapBloque;

  const _TimelineDia({
    required this.bloques,
    required this.conflictivos,
    required this.rango,
    required this.pixelesPorMinuto,
    required this.anchoColumnaHora,
    required this.esActividadActual,
    required this.onTapBloque,
  });

  @override
  Widget build(BuildContext context) {
    final int totalMinutos = rango.fin.difference(rango.inicio).inMinutes;
    final double alturaTotal = totalMinutos * pixelesPorMinuto;
    final int horaInicioEje = rango.inicio.hour;
    final int horaFinEje = rango.fin.hour;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: alturaTotal,
          width: constraints.maxWidth,
          child: Stack(
            children: [
              // ---- Marcas de hora + línea vertical guía ----
              for (int h = horaInicioEje; h <= horaFinEje; h++)
                Positioned(
                  top: (h - horaInicioEje) * 60 * pixelesPorMinuto - 8,
                  left: 0,
                  child: SizedBox(
                    width: anchoColumnaHora,
                    child: Text(
                      "${h.toString().padLeft(2, '0')}:00",
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ),
                ),
              Positioned(
                left: anchoColumnaHora - 1,
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: Colors.grey.shade300),
              ),

              // ---- Bloques de actividad ----
              for (final bloque in bloques)
                Builder(builder: (context) {
                  final topOffset = bloque.horaInicio.difference(rango.inicio).inMinutes *
                      pixelesPorMinuto;
                  final alturaBloque =
                  (bloque.calcularDuracion().inMinutes * pixelesPorMinuto).clamp(48.0, double.infinity);
                  final bool conflicto = conflictivos.contains(bloque);
                  final bool actual = esActividadActual(bloque);

                  return Positioned(
                    top: topOffset,
                    left: anchoColumnaHora + 12,
                    right: 0,
                    height: alturaBloque,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Punto conector sobre la línea del eje
                        Positioned(
                          left: -19,
                          top: alturaBloque / 2 - 5,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: conflicto
                                  ? Colors.red
                                  : bloque.actividad.completada
                                  ? Colors.green
                                  : actual
                                  ? Colors.blue
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        _BloqueTimelineTile(
                          bloque: bloque,
                          conflicto: conflicto,
                          actual: actual,
                          onTap: () => onTapBloque(bloque),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

// TARJETA individual de una actividad dentro del timeline
class _BloqueTimelineTile extends StatelessWidget {
  final BloqueHorario bloque;
  final bool conflicto;
  final bool actual;
  final VoidCallback onTap;

  const _BloqueTimelineTile({
    required this.bloque,
    required this.conflicto,
    required this.actual,
    required this.onTap,
  });

  String _formatearHora(DateTime hora) => DateFormat('HH:mm').format(hora);

  String _formatearDuracion(Duration duracion) {
    if (duracion.inHours > 0) {
      final horas = duracion.inHours;
      final minutos = duracion.inMinutes.remainder(60);
      if (minutos == 0) return "$horas ${horas == 1 ? 'hora' : 'horas'}";
      return "$horas h $minutos min";
    }
    return "${duracion.inMinutes} min";
  }

  @override
  Widget build(BuildContext context) {
    final actividad = bloque.actividad;
    final bool completada = actividad.completada;

    Color colorBorde;
    if (conflicto) {
      colorBorde = Colors.red.shade400;
    } else if (actual) {
      colorBorde = Colors.blue.shade300;
    } else {
      colorBorde = Colors.grey.shade200;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: conflicto ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorBorde, width: conflicto || actual ? 2 : 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          actividad.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            decoration: completada ? TextDecoration.lineThrough : null,
                            color: completada ? Colors.black45 : Colors.black87,
                          ),
                        ),
                      ),
                      if (completada)
                        const Icon(Icons.check_circle, color: Colors.green, size: 18)
                      else if (conflicto)
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_formatearHora(bloque.horaInicio)} - ${_formatearHora(bloque.horaFin)}"
                        " · ${_formatearDuracion(actividad.duracion)}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  if (conflicto)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Se solapa con otra actividad",
                        style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 20),
          ],
        ),
      ),
    );
  }
}

// ESTADO VACÍO
class _SinActividades extends StatelessWidget {
  const _SinActividades();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_available, size: 70, color: Colors.grey.shade400),
              const SizedBox(height: 18),
              const Text("No hay actividades",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("No tienes actividades programadas para este día.",
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}