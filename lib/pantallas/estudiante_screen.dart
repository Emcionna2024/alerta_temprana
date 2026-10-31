import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EstudianteScreen extends StatefulWidget {
  final Map<String, dynamic> usuarioLogueado;
  final String? tokenJwt;

  const EstudianteScreen({
    super.key,
    required this.usuarioLogueado,
    this.tokenJwt,
  });

  @override
  State<EstudianteScreen> createState() => _EstudianteScreenState();
}

class _EstudianteScreenState extends State<EstudianteScreen> {
  List<dynamic> avisosEstudiante = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarAvisosEstudiante();
  }

  Future<void> _cargarAvisosEstudiante() async {
    try {
      final url = Uri.parse('http://localhost:3000/api/early-notices');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.tokenJwt ?? widget.usuarioLogueado['token']}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          avisosEstudiante = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('No se pudieron cargar los avisos');
      }
    } catch (e) {
      print('Error cargando avisos de estudiante: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Avisos para Alumnos'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos para Alumnos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _cargarAvisosEstudiante();
            },
          )
        ],
      ),
      body: avisosEstudiante.isEmpty
          ? const Center(
              child: Text(
                'No hay novedades de ausencias docentes activas.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: avisosEstudiante.length,
              itemBuilder: (context, index) {
                final aviso = avisosEstudiante[index];
                
                // Mapeamos los campos reales devueltos por el backend de Prisma
                final materia = aviso['subject']?['nombre'] ?? 'Materia';
                final curso = aviso['course']?['nombre'] ?? 'Curso';
                final docente = aviso['teacherUser'] != null 
                    ? 'Prof. ${aviso['teacherUser']['firstName'] ?? ''} ${aviso['teacherUser']['lastName'] ?? ''}'
                    : 'Docente responsable';
                final fecha = aviso['classDate'] != null ? aviso['classDate'].toString().split('T')[0] : '';
                final horario = aviso['startTime'] ?? '';
                final mensaje = aviso['reason'] ?? 'Sin motivo especificado';
                final tipoAviso = aviso['type'] == 'LATE_ARRIVAL' ? 'Llegada Tarde' : 'Inasistencia Total';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF1E88E5).withOpacity(0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1565C0).withOpacity(0.12),
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
                              materia,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
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
                                '$fecha\n$horario hs',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$docente • $curso ($tipoAviso)',
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
                          mensaje,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Color(0xFF263238),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: Colors.teal.shade600, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                'Aviso Institucional Activo',
                                style: TextStyle(
                                  color: Colors.teal.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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