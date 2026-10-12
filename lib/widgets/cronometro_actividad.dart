import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _FaseCronometro { antes, enCurso, terminada }

class CronometroActividad extends StatefulWidget {
  // Fecha y hora exactas en que empieza ESTA ocurrencia de la actividad
  final DateTime inicio;
  final Duration duracion;

  const CronometroActividad({
    super.key,
    required this.inicio,
    required this.duracion,
  });

  @override
  State<CronometroActividad> createState() => _CronometroActividadState();
}

class _CronometroActividadState extends State<CronometroActividad>
    with WidgetsBindingObserver {
  Timer? _timer;
  late _FaseCronometro _faseAnterior;

  DateTime get _fin => widget.inicio.add(widget.duracion);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _faseAnterior = _faseActual();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _actualizar());
  }

  @override
  void didUpdateWidget(CronometroActividad anterior) {
    super.didUpdateWidget(anterior);
    // Si cambió la hora o la duración se recalcula el estado, sin vibrar
    if (anterior.inicio != widget.inicio ||
        anterior.duracion != widget.duracion) {
      _faseAnterior = _faseActual();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    // Al volver a la app se refresca de inmediato
    if (estado == AppLifecycleState.resumed) {
      _actualizar();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  _FaseCronometro _faseActual() {
    final ahora = DateTime.now();
    if (ahora.isBefore(widget.inicio)) return _FaseCronometro.antes;
    if (ahora.isBefore(_fin)) return _FaseCronometro.enCurso;
    return _FaseCronometro.terminada;
  }

  void _actualizar() {
    if (!mounted) return;

    final fase = _faseActual();

    // Solo vibra si el final ocurrió "en vivo" (hace pocos segundos), no si
    // el usuario vuelve a la app mucho después de que terminó.
    final bool acabaDeTerminar = _faseAnterior == _FaseCronometro.enCurso &&
        fase == _FaseCronometro.terminada &&
        DateTime.now().difference(_fin) < const Duration(seconds: 3);

    if (acabaDeTerminar) {
      HapticFeedback.vibrate();
    }

    _faseAnterior = fase;
    setState(() {});
  }

  // 05:00, 59:59 o 1:00:00 cuando dura una hora o más
  String _formato(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final horas = d.inHours;
    final minutos = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final segundos = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return horas > 0 ? '$horas:$minutos:$segundos' : '$minutos:$segundos';
  }

  String _hhmm(DateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final fase = _faseActual();

    double progreso;
    String tiempo;
    String mensaje;
    Color colorAro;
    Color colorTexto = Colors.black87;

    if (fase == _FaseCronometro.antes) {
      progreso = 1.0;
      tiempo = _formato(widget.duracion);
      mensaje = 'Empieza a las ${_hhmm(widget.inicio)}';
      colorAro = Colors.grey;
    } else if (fase == _FaseCronometro.enCurso) {
      final restante = _fin.difference(DateTime.now());
      final total = widget.duracion.inMilliseconds;
      progreso = total == 0
          ? 0.0
          : (restante.inMilliseconds / total).clamp(0.0, 1.0).toDouble();
      tiempo = _formato(restante);
      mensaje = 'Termina a las ${_hhmm(_fin)}';
      colorAro = Colors.green;
    } else {
      progreso = 0.0;
      tiempo = '00:00';
      mensaje = '¡Tiempo terminado!';
      colorAro = Colors.orange.shade800;
      colorTexto = Colors.orange.shade800;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progreso,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(colorAro),
                ),
              ),
              Text(
                tiempo,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: colorTexto,
                  // Dígitos del mismo ancho: el número no "baila" cada segundo
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          mensaje,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorTexto,
          ),
        ),
      ],
    );
  }
}
