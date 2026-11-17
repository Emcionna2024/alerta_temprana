import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // [MODIFICACIÓN]: Requerido para limpiar credenciales al cerrar sesión
import 'login_screen.dart'; // [MODIFICACIÓN]: Importación para redirigir tras el cierre de sesión
import 'docente_emision_screen.dart';
import 'docente_historial_screen.dart';
import 'docente_gestion_screen.dart';
import 'estudiante_screen.dart';
import 'dashboard_screen.dart'; // [MODIFICACIÓN]: Importación del nuevo Dashboard / Action Hub

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

  // [MODIFICACIÓN]: Método para limpiar la sesión local y restablecer la pila de navegación
  Future<void> _cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Elimina tokens y datos de sesión persistidos

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Elimina todas las pantallas previas del historial
    );
  }

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
        // [MODIFICACIÓN]: Dashboard integrado en el índice 0 como centro de accesos directos
        DashboardScreen(
          usuarioLogueado: widget.usuarioLogueado, 
          tokenJwt: widget.tokenJwt,
          onIrAEmission: () => setState(() => _indiceActual = 1),
          onIrAHistorial: () => setState(() => _indiceActual = 2),
          onIrAGestion: () => setState(() => _indiceActual = 3),
        ),
        DocenteEmisionScreen(
          onAvisoPublicado: () {
            // [MODIFICACIÓN]: Redirige al historial (índice 2) tras publicar
            setState(() => _indiceActual = 2);
            
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

      // [MODIFICACIÓN]: 4 destinos sincronizados con las pantallas del rol docente
      destinos = const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
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
          label: 'Editar Aviso Emitido',
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
      appBar: AppBar(
        title: const Text('Panel Institucional'),
        // [MODIFICACIÓN]: Botón de retroceso condicional en el AppBar para retornar al Dashboard (índice 0)
        leading: _indiceActual > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Volver al Dashboard',
                onPressed: () => setState(() => _indiceActual = 0),
              )
            : null,
        actions: [
          // [MODIFICACIÓN]: Botón de cierre de sesión corporativo en la AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: pantallas[_indiceActual],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F120F), // [MODIFICACIÓN]: Color secundario (#0F120F) para el fondo de la barra
          border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            // [MODIFICACIÓN]: Reemplazo del color anterior por el color primario (#F50E11) con opacidad para el indicador
            indicatorColor: const Color(0xFFF50E11).withOpacity(0.15),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Color(0xFFF50E11), // [MODIFICACIÓN]: Texto activo con color primario (#F50E11)
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                );
              }
              return const TextStyle(color: Color(0xFF94A3B8), fontSize: 12);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFFF50E11)); // [MODIFICACIÓN]: Icono activo con color primario (#F50E11)
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