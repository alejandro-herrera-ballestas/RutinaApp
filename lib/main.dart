import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rutina_app/screens/login_screen.dart';
import 'package:rutina_app/utils/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nvevfwmpbgbbjfwlyabe.supabase.co',
    anonKey: 'sb_publishable_8Fz72K1oNMtI-O2g9HcXuA_dna3UmzV',
  );

  await initializeDateFormatting('es_ES', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      home: const LoginScreen(),
    );
  }
}