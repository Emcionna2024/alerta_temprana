import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // [MODIFICACIÓN]: Obligatorio para traducir widgets nativos de Flutter (calendarios, diálogos, etc.)
import 'pantallas/login_screen.dart';

void main() {
  runApp(const AlertaTempranaApp());
}

class AlertaTempranaApp extends StatelessWidget {
  const AlertaTempranaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alerta Temprana',
      
      // [MODIFICACIÓN]: Delegados de internacionalización para Material, Widgets y Cupertino
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // [MODIFICACIÓN]: Restringe y habilita las variantes de español soportadas por el motor
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('es', 'AR'),
        Locale('es'),
      ],
      
      // [MODIFICACIÓN]: Fuerza el idioma por defecto de la interfaz en todo el ciclo de vida
      locale: const Locale('es', 'ES'),

      // Configuración de tema visual claro basado en la paleta institucional
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Neutral
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF50E11), // Primario
          primary: const Color(0xFFF50E11),
          secondary: const Color(0xFF0F120F),  // Secundario
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F120F),
          foregroundColor: Colors.white,
        ),
      ),
      
      home: const LoginScreen(),
    );
  }
}