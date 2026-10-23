import 'package:flutter/material.dart';
import 'docente_emision_screen.dart';
import 'docente_historial_screen.dart';
import 'estudiante_screen.dart';

class ContenedorScreen extends StatefulWidget {
  const ContenedorScreen({super.key});

  @override
  State<ContenedorScreen> createState() => _ContenedorScreenState();
}

class _ContenedorScreenState extends State<ContenedorScreen> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      DocenteEmisionScreen(
        onAvisoPublicado: () {
          setState(() {});
        },
      ),
      const DocenteHistorialScreen(),
      const EstudianteScreen(),
    ];

    return Scaffold(
      body: pantallas[_indiceActual],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0F1D),
          border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: const Color(0xFF0A0F1D),
            indicatorColor: const Color(0xFF00D2A0).withOpacity(0.15),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Color(0xFF00D2A0),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                );
              }
              return const TextStyle(color: Color(0xFF94A3B8), fontSize: 12);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFF00D2A0));
              }
              return const IconThemeData(color: Color(0xFF94A3B8));
            }),
          ),
          child: NavigationBar(
            selectedIndex: _indiceActual,
            onDestinationSelected: (index) => setState(() => _indiceActual = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.edit_calendar_outlined),
                selectedIcon: Icon(Icons.edit_calendar),
                label: 'Emitir Aviso',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'Historial',
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: 'Alumnos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}