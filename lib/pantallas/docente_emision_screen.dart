import 'package:flutter/material.dart';
import '../modelos/notificacion_ausencia.dart';

class DocenteEmisionScreen extends StatefulWidget {
  final VoidCallback onAvisoPublicado;
  const DocenteEmisionScreen({super.key, required this.onAvisoPublicado});

  @override
  State<DocenteEmisionScreen> createState() => _DocenteEmisionScreenState();
}

class _DocenteEmisionScreenState extends State<DocenteEmisionScreen> {
  final Map<String, Map<String, List<String>>> datosDocentes = {
    'Prof. Carlos Benítez': {
      'Programación I': ['1° Año A', '1° Año B'],
      'Bases de Datos': ['2° Año Única'],
    },
    'Prof. Laura Gómez': {
      'Sistemas Operativos': ['2° Año A', '2° Año B'],
      'Redes y Comunicaciones': ['3° Año Única'],
    },
  };

  String? selectedDocente;
  String? selectedMateria;
  String? selectedCurso;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String _generarTextoMensaje() {
    if (selectedDocente == null ||
        selectedMateria == null ||
        selectedCurso == null ||
        selectedDate == null ||
        selectedTime == null) {
      return 'Complete todos los desplegables, fecha y horario para generar el aviso automático.';
    }

    final fechaStr =
        '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}';
    final horaStr =
        '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')} hs';

    return 'El/La docente $selectedDocente informa su inasistencia para la cátedra de "$selectedMateria" '
        '($selectedCurso) el día $fechaStr a las $horaStr por razones de fuerza mayor.';
  }

  bool get _formularioValido =>
      selectedDocente != null &&
      selectedMateria != null &&
      selectedCurso != null &&
      selectedDate != null &&
      selectedTime != null;

  Future<void> _elegirFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _elegirHorario() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  void _publicarAusencia() {
    if (!_formularioValido) return;

    final fechaStr =
        '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}';
    final horaStr =
        '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')} hs';

    final nuevaAlerta = NotificacionAusencia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      docente: selectedDocente!,
      materia: selectedMateria!,
      curso: selectedCurso!,
      fecha: fechaStr,
      horario: horaStr,
      mensaje: _generarTextoMensaje(),
      fechaEmision: DateTime.now(),
    );

    RepositorioNotificaciones.lista.insert(0, nuevaAlerta);
    widget.onAvisoPublicado();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aviso emitido y enlazado con la red de estudiantes.'),
        backgroundColor: Color(0xFF00D2A0),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      selectedDocente = null;
      selectedMateria = null;
      selectedCurso = null;
      selectedDate = null;
      selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final listaMaterias = selectedDocente != null
        ? datosDocentes[selectedDocente]!.keys.toList()
        : <String>[];

    final listaCursos = (selectedDocente != null && selectedMateria != null)
        ? datosDocentes[selectedDocente]![selectedMateria]!
        : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00D2A0).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Color(0xFF00D2A0), size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESPACIO DOCENTE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D2A0),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Emitir Aviso Temprano',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown Docente
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF132238),
              decoration: const InputDecoration(
                labelText: 'Docente responsable',
                prefixIcon: Icon(Icons.person_outline),
              ),
              value: selectedDocente,
              items: datosDocentes.keys.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) {
                setState(() {
                  selectedDocente = val;
                  selectedMateria = null;
                  selectedCurso = null;
                });
              },
            ),
            const SizedBox(height: 14),

            // Dropdown Materia
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF132238),
              decoration: const InputDecoration(
                labelText: 'Materia',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              value: selectedMateria,
              items: listaMaterias.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: selectedDocente == null
                  ? null
                  : (val) {
                      setState(() {
                        selectedMateria = val;
                        selectedCurso = null;
                      });
                    },
            ),
            const SizedBox(height: 14),

            // Dropdown Curso
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF132238),
              decoration: const InputDecoration(
                labelText: 'Curso / División',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
              value: selectedCurso,
              items: listaCursos.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: selectedMateria == null ? null : (val) => setState(() => selectedCurso = val),
            ),
            const SizedBox(height: 14),

            // Botones de Fecha y Horario con diseño Glassmorphism oscuro
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF132238),
                      side: const BorderSide(color: Color(0xFF1E293B)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _elegirFecha,
                    icon: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF38BDF8)),
                    label: Text(
                      selectedDate == null
                          ? 'Fecha'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF132238),
                      side: const BorderSide(color: Color(0xFF1E293B)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _elegirHorario,
                    icon: const Icon(Icons.schedule_outlined, size: 18, color: Color(0xFF38BDF8)),
                    label: Text(
                      selectedTime == null
                          ? 'Horario'
                          : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Tarjeta del Mensaje Bloqueado con estilo módulo EduQuest
            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1B2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _formularioValido
                      ? const Color(0xFFF59E0B).withOpacity(0.5) // Acento de alerta ámbar
                      : const Color(0xFF1E293B),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(0, 10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'COMUNICACIÓN INSTITUCIONAL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_outline, size: 14, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Mensaje Preescrito Oficial',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _generarTextoMensaje(),
                    style: TextStyle(
                      color: _formularioValido ? const Color(0xFFE2E8F0) : const Color(0xFF64748B),
                      fontSize: 13.5,
                      height: 1.5,
                      fontStyle: _formularioValido ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón de emisión estilo EduQuest
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D2A0),
                foregroundColor: const Color(0xFF0A0F1D),
                elevation: 0,
                disabledBackgroundColor: const Color(0xFF1E293B),
                disabledForegroundColor: const Color(0xFF475569),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _formularioValido ? _publicarAusencia : null,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'Emitir Aviso Temprano',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}