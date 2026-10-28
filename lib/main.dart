import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'servicios/fcm_service.dart'; // 2. Asegúrate de que esta ruta coincida con la ubicación de tu servicio FCM
import 'pantallas/contenedor_screen.dart';
import 'firebase_options.dart'; // El archivo generado por la herramienta que importas correctamente
import 'pantallas/login_screen.dart';

void main() async {
  // Asegura que se inicialicen los bindings antes de arrancar
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase usando las opciones automáticas para cada plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 

  // Inicializar FCM (pasando el ID del usuario logueado, por ejemplo, alumno o docente ID = 1)
  // Aquí puedes llamar a tu servicio una vez que Firebase esté listo:
  // await FcmService.inicializar(usuarioId: 1); 

  runApp(const EduQuestAusenciasApp());
}

class EduQuestAusenciasApp extends StatelessWidget {
  const EduQuestAusenciasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduQuest - Alerta Temprana',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F1D),
        
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D2A0),     // Menta institucional
          secondary: Color(0xFF38BDF8),   // Cian tecnológico
          surface: Color(0xFF0F1B2E),     // Superficie de tarjetas
          error: Color(0xFFEF4444),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0F1D),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF132238),
          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIconColor: const Color(0xFF38BDF8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E293B)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E293B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00D2A0), width: 1.5),
          ),
        ),
      ),
      // En tu main.dart:
      home: LoginScreen(),
      );
  }
}
