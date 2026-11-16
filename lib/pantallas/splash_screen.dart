import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'contenedor_screen.dart';
import 'dart:convert';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  // [EXPLICACIÓN TÉCNICA]: Verifica el almacenamiento local antes de enrutar
  Future<void> _verificarSesion() async {
    // Breve retardo visual estético para la pantalla de carga (1.5 segundos)
    await Future.delayed(const Duration(milliseconds: 1500));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Clave del token JWT guardado en login
    final usuarioStr = prefs.getString('usuarioLogueado'); // Datos del usuario

    if (!mounted) return;

    // Si existen credenciales válidas, restauramos la sesión sin pasar por el login
    if (token != null && token.isNotEmpty && usuarioStr != null) {
      try {
        final Map<String, dynamic> usuario = jsonDecode(usuarioStr);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ContenedorScreen(
              usuarioLogueado: usuario,
              tokenJwt: token,
            ),
          ),
        );
        return;
      } catch (e) {
        // Si el JSON falla, limpiamos y mandamos al login por seguridad
        await prefs.clear();
      }
    }

    // Si no hay sesión, redirige al Login barriendo la ruta anterior
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFf8f9fa), // [MODIFICACIÓN]: Fondo secundario institucional
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 72,
              color: Color(0xFFF50E11), // [MODIFICACIÓN]: Ícono con color primario institucional
            ),
            SizedBox(height: 24),
            Text(
              'Alerta Temprana',
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              color: Color(0xFFF50E11), // [MODIFICACIÓN]: Indicador de carga primario
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}