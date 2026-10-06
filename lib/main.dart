import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rutina_app/screens/login_screen.dart';
import 'package:rutina_app/utils/global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nvevfwmpbgbbjfwlyabe.supabase.co',
    publishableKey: 'sb_publishable_8Fz72K1oNMtI-O2g9HcXuA_dna3UmzV',
  );

  await initializeDateFormatting('es_ES', null);

  // NUEVO: prepara las notificaciones locales (zona horaria + canal).
  await notificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Textos de los componentes de Material (selector de fecha, hora,
      // botones "Aceptar/Cancelar"...) en español. Sin esto, el selector de
      // fecha del calendario falla con "No MaterialLocalizations found".
      locale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      navigatorObservers: [routeObserver],
      home: const LoginScreen(),
    );
  }
}
