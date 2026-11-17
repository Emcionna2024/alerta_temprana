import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:url_launcher/url_launcher.dart';// [MODIFICACIÓN]: Importación requerida para el manejo de URIs externas (WhatsApp)

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> usuarioLogueado;
  final String? tokenJwt;
  final VoidCallback onIrAEmission;
  final VoidCallback onIrAHistorial;
  final VoidCallback onIrAGestion;

  const DashboardScreen({
    super.key,
    required this.usuarioLogueado,
    this.tokenJwt,
    required this.onIrAEmission,
    required this.onIrAHistorial,
    required this.onIrAGestion,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String get _nombreUsuario {
    final nombre = widget.usuarioLogueado['firstName'] ?? 'Usuario';
    final rol = widget.usuarioLogueado['rol'] ?? 'Docente';
    return '$nombre ($rol)';
  }

  // [MODIFICACIÓN]: Método asíncrono para validar y abrir el enlace externo de WhatsApp
  Future<void> _abrirWhatsApp() async {
    final Uri urlWhatsApp = Uri.parse('https://whatsapp.com/channel/0029Vb6ErnN59PwVujusXM0J');
    try {
      if (await canLaunchUrl(urlWhatsApp)) {
        await launchUrl(urlWhatsApp, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir el enlace $urlWhatsApp';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el canal de WhatsApp: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Tarjeta de Bienvenida Institucional ---
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF0F120F), // Color secundario institucional oscuro
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PANEL INSTITUCIONAL',
                    style: TextStyle(
                      color: Color(0xFFF50E11), // Color primario
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hola, $_nombreUsuario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sistema de Alertas Tempranas',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Título de Sección: Accesos Rápidos ---
            const Text(
              'ACCESOS RÁPIDOS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            // --- Tarjeta de Acceso 1: Emitir Aviso ---
            _buildActionCard(
              titulo: 'Emitir Aviso Temprano',
              subtitulo: 'Crear y enviar notificaciones de ausencia o tardanza',
              icono: Icons.edit_calendar_rounded,
              colorPrincipal: const Color(0xFFF50E11),
              onTap: widget.onIrAEmission,
            ),
            const SizedBox(height: 14),

            // --- Tarjeta de Acceso 2: Historial ---
            _buildActionCard(
              titulo: 'Historial de Avisos',
              subtitulo: 'Consultar el registro de avisos emitidos y su estado',
              icono: Icons.history_rounded,
              colorPrincipal: const Color(0xFF0D6EFD),
              onTap: widget.onIrAHistorial,
            ),
            const SizedBox(height: 14),

            // --- Tarjeta de Acceso 3: Editar / Gestionar ---
            _buildActionCard(
              titulo: 'Editar Aviso Emitido',
              subtitulo: 'Modificar o dar de baja avisos vigentes',
              icono: Icons.edit_note_rounded,
              colorPrincipal: const Color(0xFF64748B),
              onTap: widget.onIrAGestion,
            ),
            const SizedBox(height: 24),

            // --- Sección: Canales Oficiales ---
            const Text(
              'CANALES OFICIALES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            // --- Tarjeta de Acceso 4: Difusión WhatsApp ---
            _buildActionCard(
              titulo: 'Difusión WhatsApp',
              subtitulo: 'Canal oficial institucional de avisos y novedades',
              icono: Icons.chat_bubble_outline_rounded,
              colorPrincipal: const Color(0xFF25D366),
              onTap: _abrirWhatsApp,
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir tarjetas de navegación uniformes
  Widget _buildActionCard({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color colorPrincipal,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorPrincipal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: colorPrincipal, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F120F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}