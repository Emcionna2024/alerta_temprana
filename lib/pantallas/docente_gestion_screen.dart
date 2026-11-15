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
      // Consultamos directo al endpoint general validado por el Token JWT
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
          avisos = listaTemporal;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error cargando avisos para gestionar: $e');
      setState(() => _isLoading = false);
    }
  }

  // Diálogo para modificar el motivo del aviso
  Future<void> _editarAvisoModal(Map<String, dynamic> aviso) async {
    final razonController = TextEditingController(text: aviso['reason'] ?? '');
    
    final modificado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // [MODIFICACIÓN]: Fondo blanco para diálogo
        title: const Text('Modificar Aviso Temprano', style: TextStyle(color: Color(0xFF0F120F), fontWeight: FontWeight.bold)), // [MODIFICACIÓN]: Texto oscuro
        content: TextField(
          controller: razonController,
          maxLines: 4,
          style: const TextStyle(color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto oscuro legible
          decoration: const InputDecoration(
            labelText: 'Motivo / Mensaje',
            labelStyle: TextStyle(color: Color(0xFF64748B)), // [MODIFICACIÓN]: Etiqueta neutral legible
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFCBD5E1))), // [MODIFICACIÓN]: Borde claro
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFF50E11), width: 1.5)), // [MODIFICACIÓN]: Foco primario (#F50E11)
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))), // [MODIFICACIÓN]: Color neutral
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF50E11), // [MODIFICACIÓN]: Fondo primario (#F50E11)
              foregroundColor: Colors.white, // [MODIFICACIÓN]: Texto blanco
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar Cambios'),
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
          const SnackBar(content: Text('Aviso modificado y sincronizado correctamente'), backgroundColor: Color(0xFFF50E11)), // [MODIFICACIÓN]: Snack con color primario
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
        backgroundColor: Colors.white, // [MODIFICACIÓN]: Fondo blanco
        title: const Text('Eliminar aviso', style: TextStyle(color: Color(0xFF0F120F), fontWeight: FontWeight.bold)), // [MODIFICACIÓN]: Texto oscuro
        content: const Text(
          '¿Deseas dar de baja este aviso? Dejará de verse en la web y para los alumnos.', 
          style: TextStyle(color: Color(0xFF64748B)), // [MODIFICACIÓN]: Texto auxiliar legible
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))), // [MODIFICACIÓN]: Neutral
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
          const SnackBar(content: Text('Aviso eliminado correctamente'), backgroundColor: Color(0xFFF50E11)), // [MODIFICACIÓN]: Color primario
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF50E11))) // [MODIFICACIÓN]: Indicador primario (#F50E11)
          : RefreshIndicator(
              color: const Color(0xFFF50E11), // [MODIFICACIÓN]: Color primario (#F50E11)
              onRefresh: _cargarAvisos,
              child: avisos.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            'No hay avisos activos para modificar o eliminar.',
                            style: TextStyle(color: Color(0xFF64748B)), // [MODIFICACIÓN]: Texto legible
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
                          color: Colors.white, // [MODIFICACIÓN]: Fondo de tarjeta blanco
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), 
                            side: const BorderSide(color: Color(0xFFCBD5E1)), // [MODIFICACIÓN]: Borde claro neutral
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
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto oscuro
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
                                const SizedBox(height: 4),
                                Text('Fecha de clase: $fecha', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)), // [MODIFICACIÓN]: Texto secundario legible
                                const Divider(color: Color(0xFFCBD5E1), height: 16), // [MODIFICACIÓN]: Divisor claro
                                Text(aviso['reason'] ?? '', style: const TextStyle(color: Color(0xFF0F120F), fontSize: 13)), // [MODIFICACIÓN]: Texto oscuro de motivo
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _editarAvisoModal(aviso),
                                      icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0D6EFD)), // [MODIFICACIÓN]: Azul terciario (#0D6EFD)
                                      label: const Text('Modificar', style: TextStyle(color: Color(0xFF0D6EFD), fontSize: 12)), // [MODIFICACIÓN]: Azul terciario
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