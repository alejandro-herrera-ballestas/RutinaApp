import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rutina_app/models/horario.dart';
import 'package:rutina_app/services/auth_service.dart';
import 'package:rutina_app/services/actividad_service.dart';

final ActividadService actividadService = ActividadService();
final AuthService authService = AuthService();

final Horario horarioDelDia = Horario(bloques: []);

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

final SupabaseClient supabase = Supabase.instance.client;
