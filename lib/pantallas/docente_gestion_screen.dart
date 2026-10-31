import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DocenteGestionScreen extends StatefulWidget {
  final Map<String, dynamic> usuarioLogueado;
  final String? tokenJwt;

  const DocenteGestionScreen({
    super.key,
    required this.usuarioLogueado,
    this.tokenJwt,
  });

  @override
  State<DocenteGestionScreen> createState() => _DocenteGestionScreenState();
}

class _DocenteGestionScreenState extends State<DocenteGestionScreen> {
  List<dynamic> avisos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarAvisos();
  }

  Future<void> _cargarAvisos() async {
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
          avisos = data is List ? data : (data['notices'] ?? data['data'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error cargando avisos para editar: $e');
      setState(() => _isLoading = false);
    }
  }

  // Diálogo para modificar el motivo del aviso
  Future<void> _editarAvisoModal(Map<String, dynamic> aviso) async {
    final razonController = TextEditingController(text: aviso['reason'] ?? '');
    
    final modificado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF132238),
        title: const Text('Modificar Aviso Temprano', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: razonController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Motivo / Mensaje',
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D2A0))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D2A0)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar Cambios', style: TextStyle(color: Color(0xFF0A0F1D))),
          ),
        ],
      ),
    );

    if (modificado != true) return;

    try {
      final url = Uri.parse('http://localhost:3000/api/early-notices/${aviso['id']}');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.tokenJwt ?? widget.usuarioLogueado['token']}',
        },
        body: jsonEncode({
          'reason': razonController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        _cargarAvisos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aviso modificado y sincronizado correctamente'), backgroundColor: Color(0xFF00D2A0)),
        );
      } else {
        throw Exception('No se pudo actualizar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al modificar: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  // Método para eliminar / desactivar el aviso
  Future<void> _eliminarAviso(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF132238),
        title: const Text('Eliminar aviso', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Deseas dar de baja este aviso? Dejará de verse en la web y para los alumnos.', 
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final url = Uri.parse('http://localhost:3000/api/early-notices/$id/deactivate');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.tokenJwt ?? widget.usuarioLogueado['token']}',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _cargarAvisos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aviso eliminado correctamente'), backgroundColor: Color(0xFF00D2A0)),
        );
      } else {
        throw Exception('No se pudo eliminar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión y Edición de Avisos'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D2A0)))
          : RefreshIndicator(
              color: const Color(0xFF00D2A0),
              onRefresh: _cargarAvisos,
              child: avisos.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            'No hay avisos activos para modificar o eliminar.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: avisos.length,
                      itemBuilder: (context, index) {
                        final aviso = avisos[index];
                        final materia = aviso['teacherSubject']?['subject']?['nombre'] ?? 'Materia';
                        final curso = aviso['course']?['nombre'] ?? 'Curso';
                        final fecha = aviso['classDate'] ?? '';

                        return Card(
                          color: const Color(0xFF132238),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), 
                            side: const BorderSide(color: Color(0xFF1E293B)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
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
                                const SizedBox(height: 4),
                                Text('Fecha de clase: $fecha', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                const Divider(color: Color(0xFF1E293B), height: 16),
                                Text(aviso['reason'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _editarAvisoModal(aviso),
                                      icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF38BDF8)),
                                      label: const Text('Modificar', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () => _eliminarAviso(aviso['id']),
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