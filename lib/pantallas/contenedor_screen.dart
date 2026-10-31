import 'package:flutter/material.dart';
import 'docente_emision_screen.dart';
import 'docente_historial_screen.dart';
import 'docente_gestion_screen.dart';
import 'estudiante_screen.dart';

class ContenedorScreen extends StatefulWidget {
  final Map<String, dynamic> usuarioLogueado;
  final String? tokenJwt;

  const ContenedorScreen({
    super.key, 
    required this.usuarioLogueado, 
    this.tokenJwt,
  });

  @override
  State<ContenedorScreen> createState() => _ContenedorScreenState();
}

class _ContenedorScreenState extends State<ContenedorScreen> {
  int _indiceActual = 0;

  final GlobalKey<State<DocenteHistorialScreen>> _historialKey = GlobalKey<State<DocenteHistorialScreen>>();

  @override
  Widget build(BuildContext context) {
    final userData = widget.usuarioLogueado;
    
    final bool isStudent = userData['studentProfile'] != null || 
                           (userData['roles'] != null && (userData['roles'] as List).contains('STUDENT'));
    
    final bool isTeacher = userData['teacherProfile'] != null || 
                           (userData['roles'] != null && (userData['roles'] as List).contains('TEACHER'));

    final bool isAdminOrDirector = (userData['roles'] != null && 
        ((userData['roles'] as List).contains('ADMIN') || 
         (userData['roles'] as List).contains('DIRECTOR') || 
         (userData['roles'] as List).contains('PRECEPTOR')));

    final List<Widget> pantallas;
    final List<NavigationDestination> destinos;

    if (isTeacher && !isAdminOrDirector) {
      pantallas = [
        DocenteEmisionScreen(
          onAvisoPublicado: () {
            setState(() => _indiceActual = 1);
            
            final historialState = _historialKey.currentState;
            if (historialState != null) {
              (historialState as dynamic).cargarHistorialExterno();
            }
          },
          usuarioLogueado: widget.usuarioLogueado,
          tokenJwt: widget.tokenJwt,    
        ),
        DocenteHistorialScreen(
          key: _historialKey, 
          usuarioLogueado: widget.usuarioLogueado,
          tokenJwt: widget.tokenJwt,
        ),
        DocenteGestionScreen(
          usuarioLogueado: widget.usuarioLogueado,
          tokenJwt: widget.tokenJwt,
        ),
      ];

      destinos = const [
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
          icon: Icon(Icons.edit_note_outlined),
          selectedIcon: Icon(Icons.edit_note),
          label: 'Editar Aviso Emitido', // 👈 Texto corregido con mayúsculas
        ),
      ];
    } else if (isAdminOrDirector) {
      pantallas = [
        DocenteHistorialScreen(
          key: _historialKey,
          usuarioLogueado: widget.usuarioLogueado,
          tokenJwt: widget.tokenJwt,
        ),
      ];

      destinos = const [
        NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Monitoreo Global',
        ),
      ];
    } else {
      return EstudianteScreen(
        usuarioLogueado: widget.usuarioLogueado, 
        tokenJwt: widget.tokenJwt,
      );
    }

    if (_indiceActual >= pantallas.length) {
      _indiceActual = 0;
    }

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
            destinations: destinos,
          ),
        ),
      ),
    );
  }
}