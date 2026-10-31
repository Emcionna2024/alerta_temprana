import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DocenteHistorialScreen extends StatefulWidget {
  final Map<String, dynamic> usuarioLogueado;
  final String? tokenJwt;

  const DocenteHistorialScreen({
    super.key,
    required this.usuarioLogueado,
    this.tokenJwt,
  });

  @override
  State<DocenteHistorialScreen> createState() => _DocenteHistorialScreenState();
}

class _DocenteHistorialScreenState extends State<DocenteHistorialScreen> {
  List<dynamic> avisosEmitidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  // Método público para recargar externamente desde el contenedor
  Future<void> cargarHistorialExterno() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    try {
      final teacherId = widget.usuarioLogueado['teacherProfile']?['id'] ?? widget.usuarioLogueado['id'];
      final url = Uri.parse('http://localhost:3000/api/early-notices?teacherId=$teacherId');

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
          avisosEmitidos = data is List ? data : (data['notices'] ?? data['data'] ?? []);
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar el historial: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en historial: $e');
      setState(() => _isLoading = false);
    }
  }

  // Método para desactivar / eliminar un aviso desde Flutter
  Future<void> _desactivarAviso(int avisoId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF132238),
        title: const Text('Desactivar aviso', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de dar de baja este aviso temprano?', 
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, desactivar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final url = Uri.parse('http://localhost:3000/api/early-notices/$avisoId/deactivate');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.tokenJwt ?? widget.usuarioLogueado['token']}',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _cargarHistorial(); // Refrescamos la lista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aviso desactivado correctamente'), backgroundColor: Color(0xFF00D2A0)),
        );
      } else {
        throw Exception('No se pudo desactivar el aviso');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Avisos Emitidos'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D2A0)))
          : RefreshIndicator(
              color: const Color(0xFF00D2A0),
              onRefresh: _cargarHistorial,
              child: avisosEmitidos.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            'Aún no has emitido ninguna alerta de ausencia.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: avisosEmitidos.length,
                      itemBuilder: (context, index) {
                        final aviso = avisosEmitidos[index];
                        final avisoId = aviso['id'];
                        final materia = aviso['teacherSubject']?['subject']?['nombre'] ?? aviso['materia'] ?? 'Materia';
                        final curso = aviso['course']?['nombre'] ?? aviso['curso'] ?? 'Curso';
                        final fecha = aviso['classDate'] ?? aviso['fecha'] ?? '';
                        final mensaje = aviso['reason'] ?? aviso['mensaje'] ?? '';
                        final docenteNombre = widget.usuarioLogueado['firstName'] ?? '';
                        final docenteApellido = widget.usuarioLogueado['lastName'] ?? '';

                        return Card(
                          color: const Color(0xFF132238),
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFF1E293B)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      materia,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00D2A0).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        curso,
                                        style: const TextStyle(
                                          color: Color(0xFF00D2A0),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Fecha de clase: $fecha',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                ),
                                const Divider(height: 18, color: Color(0xFF1E293B)),
                                Text(
                                  mensaje,
                                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Docente: Prof. $docenteNombre $docenteApellido',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                    // Botón de eliminación / desactivación rápida
                                    TextButton.icon(
                                      onPressed: () => _desactivarAviso(avisoId),
                                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                      label: const Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}