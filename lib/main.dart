import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rutina_app/screens/main_navigator_screen.dart';
import 'package:rutina_app/utils/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const MainNavigatorScreen(),
    );
  }
}