import 'package:flutter/material.dart';
import 'package:rutina_app/services/auth_service.dart';
import 'package:rutina_app/services/actividad_service.dart';
import 'package:rutina_app/models/horario.dart';

final ActividadService actividadService = ActividadService();
final AuthService authService = AuthService();
final Horario horarioDelDia = Horario(bloques: []);
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();