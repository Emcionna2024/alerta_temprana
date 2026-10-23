import 'package:flutter/material.dart';
import 'pantallas/contenedor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        // Fondo base idéntico a la web
        scaffoldBackgroundColor: const Color(0xFF0A0F1D),
        
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D2A0),     // Menta institucional
          secondary: Color(0xFF38BDF8),   // Cian tecnológico
          surface: Color(0xFF0F1B2E),     // Superficie de tarjetas
          error: Color(0xFFEF4444),
        ),

        // Barra superior limpia y oscura
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

        // Estilo de los campos de texto y dropdowns
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
      home: const ContenedorScreen(),
    );
  }
}