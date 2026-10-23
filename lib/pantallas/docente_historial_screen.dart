import 'package:flutter/material.dart';
import '../modelos/notificacion_ausencia.dart';

class DocenteHistorialScreen extends StatefulWidget {
  const DocenteHistorialScreen({super.key});

  @override
  State<DocenteHistorialScreen> createState() => _DocenteHistorialScreenState();
}

class _DocenteHistorialScreenState extends State<DocenteHistorialScreen> {
  @override
  Widget build(BuildContext context) {
    final avisos = RepositorioNotificaciones.lista;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Avisos Emitidos'), centerTitle: true),
      body: avisos.isEmpty
          ? const Center(
              child: Text('Aún no has emitido ninguna alerta de ausencia.', style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: avisos.length,
              itemBuilder: (context, index) {
                final aviso = avisos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(aviso.materia, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                              child: Text(aviso.curso, style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Fecha: ${aviso.fecha} (${aviso.horario})', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        const Divider(height: 18),
                        Text(aviso.mensaje, style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Docente: ${aviso.docente}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            const Row(
                              children: [
                                Icon(Icons.cloud_done_outlined, size: 16, color: Colors.green),
                                SizedBox(width: 4),
                                Text('Registrado', style: TextStyle(fontSize: 11, color: Colors.green)),
                              ],
                            ),
                          ],
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