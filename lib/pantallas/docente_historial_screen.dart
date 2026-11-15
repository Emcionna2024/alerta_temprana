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
      // Llamamos directamente al endpoint general de avisos
      final url = Uri.parse('http://localhost:3000/api/early-notices');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.tokenJwt ?? widget.usuarioLogueado['token']}',
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        
        List<dynamic> listaTemporal = [];
        if (decodedBody is List) {
          listaTemporal = decodedBody;
        } else if (decodedBody is Map) {
          listaTemporal = decodedBody['notices'] ?? 
                          decodedBody['data'] ?? 
                          decodedBody['data']?['data'] ?? 
                          [];
        }

        setState(() {
          avisosEmitidos = listaTemporal;
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
        backgroundColor: Colors.white, // [MODIFICACIÓN]: Fondo blanco para diálogo
        title: const Text('Desactivar aviso', style: TextStyle(color: Color(0xFF0F120F), fontWeight: FontWeight.bold)), // [MODIFICACIÓN]: Texto oscuro
        content: const Text(
          '¿Estás seguro de dar de baja este aviso temprano?', 
          style: TextStyle(color: Color(0xFF64748B)), // [MODIFICACIÓN]: Texto secundario legible
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))), // [MODIFICACIÓN]: Color neutral
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
          const SnackBar(content: Text('Aviso desactivado correctamente'), backgroundColor: Color(0xFFF50E11)), // [MODIFICACIÓN]: Color primario (#F50E11)
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF50E11))) // [MODIFICACIÓN]: Indicador primario (#F50E11)
          : RefreshIndicator(
              color: const Color(0xFFF50E11), // [MODIFICACIÓN]: Color primario (#F50E11)
              onRefresh: _cargarHistorial,
              child: avisosEmitidos.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            'Aún no has emitido ninguna alerta de ausencia.',
                            style: TextStyle(color: Color(0xFF64748B)), // [MODIFICACIÓN]: Texto legible
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
                          color: Colors.white, // [MODIFICACIÓN]: Fondo blanco para tarjeta
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFFCBD5E1)), // [MODIFICACIÓN]: Borde claro neutral
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
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto oscuro legible
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF50E11).withOpacity(0.15), // [MODIFICACIÓN]: Primario suave
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        curso,
                                        style: const TextStyle(
                                          color: Color(0xFFF50E11), // [MODIFICACIÓN]: Texto primario (#F50E11)
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
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13), // [MODIFICACIÓN]: Texto secundario legible
                                ),
                                const Divider(height: 18, color: Color(0xFFCBD5E1)), // [MODIFICACIÓN]: Divisor claro
                                Text(
                                  mensaje,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto oscuro de motivo
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Docente: Prof. $docenteNombre $docenteApellido',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), // [MODIFICACIÓN]: Texto auxiliar legible
                                    ),
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