import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rutina_app/models/actividad.dart';
import 'package:rutina_app/models/BloqueHorario.dart';
import 'package:rutina_app/services/storage_service.dart';
import 'package:rutina_app/widgets/imagen_storage.dart';
import 'package:rutina_app/widgets/selector_paciente.dart';
import 'package:rutina_app/utils/global.dart';
import 'package:rutina_app/screens/detalle_actividad_screen.dart';

// Una actividad ya "colocada" en el calendario: dónde empieza, cuánto mide
// y en qué columna va cuando varias tarjetas quedarían una encima de otra.
class _Posicionada {
  final BloqueHorario bloque;
  final double top;
  final double altura;
  int columna = 0;
  int totalColumnas = 1;

  _Posicionada({
    required this.bloque,
    required this.top,
    required this.altura,
  });
}

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  List<String> _conflictivas = [];
  List<Actividad> _actividades = [];

  bool _cargando = true;
  String? _error;

  // Número de la carga más reciente. Con el selector de días se puede
  // cambiar de día muy rápido; así una respuesta lenta de un día anterior
  // no pisa a la del día actual.
  int _cargaActual = 0;

  DateTime _fechaSeleccionada = DateTime.now();

  // Altura aproximada de cada hora en el calendario.
  static const double _altoPorHora = 80;

  // Altura MÍNIMA de una tarjeta para que se pueda leer (nombre + hora).
  // Antes se forzaba entre 70 y 150, y una actividad de 5 minutos ocupaba
  // casi una hora y tapaba a la siguiente.
  static const double _alturaMinima = 56;

  // El calendario ahora muestra las 24 horas del día.
  static const int _horaInicial = 0;
  static const int _horaFinal = 23;

  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  // CARGAR ACTIVIDADES DESDE SUPABASE (del paciente seleccionado, para el
  // día que se esté viendo) Y REGENERAR EL HORARIO
  Future<void> _cargarActividades() async {
    final pacienteId = authService.pacienteSeleccionado?.pacienteId;
    final int miCarga = ++_cargaActual;

    setState(() {
      _cargando = true;
      _error = null;
    });

    if (pacienteId == null) {
      setState(() {
        _actividades = [];
        _cargando = false;
      });
      _regenerarHorario();
      return;
    }

    try {
      final actividades = await actividadService.obtenerActividadesConProgreso(
        pacienteId,
        _fechaSeleccionada,
      );
      if (!mounted || miCarga != _cargaActual) return;
      setState(() {
        _actividades = actividades;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted || miCarga != _cargaActual) return;
      setState(() {
        _error = "No se pudieron cargar las actividades: $e";
        _cargando = false;
      });
    }

    _regenerarHorario();
  }

  // GENERAR HORARIO
  void _regenerarHorario() {
    final conflictos = horarioDelDia.generarDesdeActividades(
      _actividades,
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

  // ============================================================
  // SELECTOR DE DÍAS (tira de la semana, arriba del calendario)
  // ============================================================

  bool _mismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Lunes de la semana en la que cae la fecha dada
  DateTime _lunesDeLaSemana(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day - (fecha.weekday - 1));
  }

  void _seleccionarDia(DateTime dia) {
    if (_mismoDia(dia, _fechaSeleccionada)) return;

    setState(() {
      _fechaSeleccionada = dia;
    });

    _cargarActividades();
  }

  // Salta una semana hacia atrás (-1) o adelante (1), al mismo día de la semana
  void _moverSemana(int semanas) {
    _seleccionarDia(
      DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day + 7 * semanas,
      ),
    );
  }

  Widget _crearSelectorDias() {
    const List<String> nombres = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    final DateTime lunes = _lunesDeLaSemana(_fechaSeleccionada);
    final DateTime hoy = DateTime.now();

    final List<Widget> dias = [];

    for (int i = 0; i < 7; i++) {
      final DateTime dia = DateTime(lunes.year, lunes.month, lunes.day + i);
      final bool seleccionado = _mismoDia(dia, _fechaSeleccionada);
      final bool esHoy = _mismoDia(dia, hoy);

      dias.add(
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _seleccionarDia(dia),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: seleccionado ? Colors.black87 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  // el día de hoy lleva borde verde para ubicarse rápido
                  color: esHoy && !seleccionado
                      ? Colors.green
                      : Colors.grey.shade300,
                  width: esHoy ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nombres[i],
                    style: TextStyle(
                      fontSize: 11,
                      color: seleccionado ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${dia.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: seleccionado ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Semana anterior',
            icon: const Icon(Icons.chevron_left),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 40),
            onPressed: () => _moverSemana(-1),
          ),
          ...dias,
          IconButton(
            tooltip: 'Semana siguiente',
            icon: const Icon(Icons.chevron_right),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 40),
            onPressed: () => _moverSemana(1),
          ),
        ],
      ),
    );
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

    _cargarActividades();
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

    _cargarActividades();
  }

  // ABRIR DETALLE DE ACTIVIDAD
  Future<void> _abrirDetalleActividad(
      BuildContext context,
      BloqueHorario bloque,
      ) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleActividadScreen(
          actividad: bloque.actividad,
          fecha: _fechaSeleccionada,
        ),
      ),
    );

    // Si se editaron o eliminaron datos,
    // actualizamos el calendario.
    if (resultado == true && mounted) {
      _cargarActividades();
    }
  }

  // ============================================================
  // POSICIONAMIENTO (aquí está la corrección de las actividades perdidas)
  // ============================================================

  // Calcula arriba/altura de cada actividad y la reparte en columnas cuando
  // dos tarjetas quedarían tapándose (por ejemplo una de 5 min a las 8:00 y
  // otra a las 8:10: cada una necesita al menos _alturaMinima para leerse).
  List<_Posicionada> _calcularPosiciones(List<BloqueHorario> bloques) {
    final List<_Posicionada> items = [];

    for (final bloque in bloques) {
      final double minutosDesdeInicio =
          (bloque.horaInicio.hour * 60 +
              bloque.horaInicio.minute -
              _horaInicial * 60)
              .toDouble();

      final double duracionMinutos =
          bloque.calcularDuracion().inMinutes.toDouble();

      final double top = (minutosDesdeInicio / 60) * _altoPorHora;

      // Altura REAL según la duración, con un mínimo para poder leerla.
      // Ya no hay máximo: una actividad de 1 hora mide una hora.
      final double altura = math.max(
        (duracionMinutos / 60) * _altoPorHora,
        _alturaMinima,
      );

      items.add(_Posicionada(bloque: bloque, top: top, altura: altura));
    }

    items.sort((a, b) => a.top.compareTo(b.top));

    // Agrupamos las tarjetas que se tocan o se tapan ("grupos") y dentro de
    // cada grupo asignamos columnas.
    final List<_Posicionada> resultado = [];
    List<_Posicionada> grupo = [];
    double finDelGrupo = -1;

    void cerrarGrupo() {
      final List<double> finDeCadaColumna = [];

      for (final item in grupo) {
        int columna = -1;

        for (int c = 0; c < finDeCadaColumna.length; c++) {
          if (finDeCadaColumna[c] <= item.top) {
            columna = c;
            break;
          }
        }

        if (columna == -1) {
          finDeCadaColumna.add(item.top + item.altura);
          columna = finDeCadaColumna.length - 1;
        } else {
          finDeCadaColumna[columna] = item.top + item.altura;
        }

        item.columna = columna;
      }

      for (final item in grupo) {
        item.totalColumnas = finDeCadaColumna.length;
      }

      resultado.addAll(grupo);
      grupo = [];
      finDelGrupo = -1;
    }

    for (final item in items) {
      if (grupo.isNotEmpty && item.top >= finDelGrupo) {
        cerrarGrupo();
      }

      grupo.add(item);
      finDelGrupo = math.max(finDelGrupo, item.top + item.altura);
    }

    if (grupo.isNotEmpty) {
      cerrarGrupo();
    }

    return resultado;
  }

  // CONSTRUIR TARJETA DE ACTIVIDAD
  // 'compacta' = tarjeta angosta (varias en paralelo) o baja: se usa una
  // miniatura más pequeña y se oculta la flecha para que el nombre y la hora
  // sigan visibles. Solo se quita la imagen si la tarjeta es MUY angosta.
  Widget _crearTarjetaActividad(
      BuildContext context,
      BloqueHorario bloque, {
      required bool compacta,
      required double ancho,
      }) {
    final actividad = bloque.actividad;

    final String horaInicio =
    DateFormat('HH:mm').format(bloque.horaInicio);

    final String horaFin =
    DateFormat('HH:mm').format(bloque.horaFin);

    final int minutos =
        bloque.calcularDuracion().inMinutes;

    // La imagen se muestra siempre, más pequeña en tarjetas compactas.
    // Solo se oculta si la tarjeta es demasiado angosta para leerse.
    final bool mostrarImagen = ancho >= 110;
    final double anchoImagen = compacta ? 44 : 65;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        _abrirDetalleActividad(context, bloque);
      },

      child: Container(
        width: double.infinity,
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),

          child: Row(
            children: [
              // IMAGEN (miniatura en tarjetas compactas)
              if (mostrarImagen)
                SizedBox(
                  width: anchoImagen,
                  height: double.infinity,
                  child: ImagenStorage(
                    bucket: StorageService.bucketActividades,
                    ruta: actividad.rutaIMG,
                    width: anchoImagen,
                    height: double.infinity,
                    placeholder: Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

              // INFORMACIÓN
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compacta ? 8 : 10,
                    vertical: 6,
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(
                        actividad.nombre,

                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: compacta ? 12 : 14,
                          fontWeight: FontWeight.bold,

                          color: actividad.completada
                              ? Colors.green.shade800
                              : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        compacta
                            ? horaInicio
                            : '$horaInicio - $horaFin · $minutos min',

                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ESTADO
              Padding(
                padding: const EdgeInsets.only(right: 6),

                child: actividad.completada
                    ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: compacta ? 16 : 20,
                )

                    : (compacta
                    ? const SizedBox.shrink()
                    : const Icon(
                  Icons.chevron_right,
                  color: Colors.black45,
                  size: 20,
                )),
              ),
            ],
          ),
        ),
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

    // Corregido: se cuentan las 24 horas completas (0 a 23 inclusive).
    final double alturaTotal =
        ((_horaFinal - _horaInicial + 1) * _altoPorHora) + 40;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 30,
        bottom: 60,
        left: 4,
        right: 4,
      ),

      child: SizedBox(
        height: alturaTotal,

        // LayoutBuilder da el ancho disponible para repartir las columnas
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 70 de margen izquierdo (horas) + 4 de margen derecho
            final double anchoUtil = constraints.maxWidth - 74;
            final List<_Posicionada> posiciones = _calcularPosiciones(bloques);

            return Stack(
              clipBehavior: Clip.none,

              children: [
                // LÍNEA VERTICAL
                Positioned(
                  left: 57,
                  top: 0,
                  bottom: 20,

                  child: Container(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                ),

                // HORAS
                for (int hora = _horaInicial;
                hora <= _horaFinal;
                hora++)

                  Positioned(
                    top: (hora - _horaInicial) * _altoPorHora - 7,
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
                // LÍNEAS HORIZONTALES
                for (int hora = _horaInicial;
                hora <= _horaFinal;
                hora++)

                  Positioned(
                    top: (hora - _horaInicial) * _altoPorHora,
                    left: 65,
                    right: 0,

                    child: Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                  ),

                // ACTIVIDADES
                for (final posicion in posiciones)
                  _crearPosicionActividad(posicion, anchoUtil),

                // LÍNEA DE HORA ACTUAL
                if (_esHoy())
                  _crearLineaHoraActual(_horaInicial),
              ],
            );
          },
        ),
      ),
    );
  }

  // POSICIÓN DE UNA ACTIVIDAD
  Widget _crearPosicionActividad(
      _Posicionada posicion,
      double anchoUtil,
      ) {
    final double anchoColumna = anchoUtil / posicion.totalColumnas;

    // Pequeño espacio entre columnas cuando hay varias lado a lado
    final double separacion = posicion.totalColumnas > 1 ? 3 : 0;

    final bool compacta =
        posicion.totalColumnas > 1 || posicion.altura < 64;

    return Positioned(
      top: posicion.top,
      left: 70 + posicion.columna * anchoColumna,
      width: anchoColumna - separacion,
      height: posicion.altura,

      child: _crearTarjetaActividad(
        context,
        posicion.bloque,
        compacta: compacta,
        ancho: anchoColumna - separacion,
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
        minutosDesdeInicio > (_horaFinal - horaInicial + 1) * 60) {
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

          // Volver a hoy
          if (!_esHoy())
            IconButton(
              tooltip: 'Ir a hoy',
              icon: const Icon(Icons.today),
              onPressed: _irAHoy,
            ),

          // Seleccionar fecha
          IconButton(
            tooltip: 'Seleccionar fecha',
            icon: const Icon(Icons.calendar_month),
            onPressed: _seleccionarFecha,
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
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
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

                        const SizedBox(height: 2),

                        // Explica por qué una actividad puede no aparecer
                        // en un día: solo salen las que se repiten ese día.
                        Text(
                          "Solo actividades que se repiten el "
                          "${DateFormat('EEEE', 'es_ES').format(_fechaSeleccionada)}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
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

            // Solo aparece para cuidadores con más de un paciente.
            SelectorPaciente(onCambio: _cargarActividades),

            // Selector de días de la semana (arriba del calendario)
            _crearSelectorDias(),

            // CONFLICTOS (con el bloqueo de la base de datos ya no deberían
            // aparecer; se deja como red de seguridad)
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
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
                  : horarioDelDia.bloques.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    "No hay actividades programadas "
                        "para este día.",
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
