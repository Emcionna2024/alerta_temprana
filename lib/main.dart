import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'servicios/fcm_service.dart';
import 'pantallas/contenedor_screen.dart';
import 'firebase_options.dart';
import 'pantallas/login_screen.dart';

void main() async {
  // Asegura que se inicialicen los bindings antes de arrancar
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase usando las opciones automáticas para cada plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 

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
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Fondo neutral general
        
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFF50E11),    // Color primario (#F50E11)
          secondary: Color(0xFF0F120F),   // Color secundario (#0F120F)
          tertiary: Color(0xFF0D6EFD),    // Color terciario (#0D6EFD)
          surface: Colors.white,
          error: Color(0xFFEF4444),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // [MODIFICACIÓN]: Fondo blanco para AppBar global
          foregroundColor: Color(0xFF0F120F), // [MODIFICACIÓN]: Texto/íconos oscuros
          elevation: 0,
          centerTitle: true, // [MODIFICACIÓN]: Centrado estándar unificado
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F120F), // [MODIFICACIÓN]: Texto oscuro legible
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Íconos oscuros
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // [MODIFICACIÓN]: Fondo blanco para campos de texto
          labelStyle: const TextStyle(color: Color(0xFF64748B)), // [MODIFICACIÓN]: Etiqueta neutral legible
          prefixIconColor: const Color(0xFF64748B), // [MODIFICACIÓN]: Icono de prefijo neutro
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)), // [MODIFICACIÓN]: Borde claro neutral
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)), // [MODIFICACIÓN]: Borde claro habilitado
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF50E11), width: 1.5), // [MODIFICACIÓN]: Foco primario (#F50E11)
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}