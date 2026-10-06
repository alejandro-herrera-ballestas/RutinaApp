import 'package:flutter/material.dart';
import 'package:rutina_app/screens/login_screen.dart';
import 'package:rutina_app/screens/main_navigator_screen.dart';
import 'package:rutina_app/utils/global.dart';

// Primera pantalla de la app. Decide a dónde ir:
//  - Hay sesión guardada  -> carga el perfil y entra directo a la app.
//  - No hay sesión        -> Login.
//  - Hay sesión pero no hay internet -> avisa y deja reintentar, SIN
//    cerrar la sesión (así no se pierde por estar sin conexión un momento).
// La sesión solo se borra cuando el usuario toca "Cerrar sesión".
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _huboError = false;

  @override
  void initState() {
    super.initState();
    _decidirPantalla();
  }

  void _irA(Widget pantalla) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  Future<void> _decidirPantalla() async {
    if (_huboError) {
      setState(() {
        _huboError = false;
      });
    }

    // Sin sesión guardada: directo al Login
    if (supabase.auth.currentSession == null) {
      _irA(const LoginScreen());
      return;
    }

    try {
      final bool restaurada = await authService.restaurarSesion();

      if (restaurada) {
        _irA(const MainNavigatorScreen());
      } else {
        // La sesión existe pero la cuenta no tiene perfil: se cierra
        await supabase.auth.signOut();
        _irA(const LoginScreen());
      }
    } catch (e) {
      debugPrint('No se pudo restaurar la sesión: $e');
      if (!mounted) return;
      setState(() {
        _huboError = true;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    await authService.cerrarSesion();
    _irA(const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      body: Center(
        child: _huboError
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 60, color: Colors.black54),
                    const SizedBox(height: 16),
                    const Text(
                      "No se pudo conectar",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Revisa tu conexión a internet e inténtalo de nuevo. "
                      "Tu sesión sigue guardada.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _decidirPantalla,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reintentar"),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _cerrarSesion,
                      child: const Text("Cerrar sesión"),
                    ),
                  ],
                ),
              )
            : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month, size: 80),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
      ),
    );
  }
}
