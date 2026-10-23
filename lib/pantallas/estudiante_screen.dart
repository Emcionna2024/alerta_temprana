import 'package:flutter/material.dart';
import '../modelos/notificacion_ausencia.dart';

class EstudianteScreen extends StatefulWidget {
  const EstudianteScreen({super.key});

  @override
  State<EstudianteScreen> createState() => _EstudianteScreenState();
}

class _EstudianteScreenState extends State<EstudianteScreen> {
  @override
  Widget build(BuildContext context) {
    final avisos = RepositorioNotificaciones.lista;

    return Scaffold(
      appBar: AppBar(title: const Text('Avisos para Alumnos'), centerTitle: true),
      body: avisos.isEmpty
          ? const Center(
              child: Text('No hay novedades de ausencias docentes activas.', style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: avisos.length,
              itemBuilder: (context, index) {
                final aviso = avisos[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    // Fondo blanco translúcido
                    color: aviso.recibida 
                        ? Colors.white.withOpacity(0.7) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: aviso.recibida 
                          ? Colors.grey.withOpacity(0.3) 
                          : const Color(0xFF1E88E5).withOpacity(0.4),
                      width: 1.2,
                    ),
                    // Sombra 3D proyectada
                    boxShadow: [
                      BoxShadow(
                        color: aviso.recibida
                            ? Colors.black.withOpacity(0.04)
                            : const Color(0xFF1565C0).withOpacity(0.18), // Sombra azul de presencia activa
                        offset: const Offset(0, 6),
                        blurRadius: 14,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              aviso.materia,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0D47A1), // Título en azul oscuro
                              ),
                            ),
                            // Badge estilizado con transparencia
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF90CAF9),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '${aviso.fecha} • ${aviso.horario}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${aviso.docente} • ${aviso.curso}',
                          style: TextStyle(
                            color: Colors.blueGrey.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        Divider(
                          height: 24, 
                          color: const Color(0xFF0D47A1).withOpacity(0.1),
                        ),
                        Text(
                          aviso.mensaje,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Color(0xFF263238),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: aviso.recibida
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, 
                                         color: Colors.teal.shade600, 
                                         size: 22),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Aviso Recibido',
                                      style: TextStyle(
                                        color: Colors.teal.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1565C0),
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor: const Color(0x661565C0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      aviso.recibida = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Notificación marcada como recibida.'),
                                        duration: Duration(seconds: 2),
                                        backgroundColor: Color(0xFF0D47A1),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.done_all_rounded, size: 18),
                                  label: const Text('Confirmar Recepción'),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}