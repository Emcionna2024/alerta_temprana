import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DocenteEmisionScreen extends StatefulWidget {
  final VoidCallback onAvisoPublicado;
  final Map<String, dynamic> usuarioLogueado;
  final String? tokenJwt;
  const DocenteEmisionScreen({
    super.key, 
    required this.onAvisoPublicado,
    required this.usuarioLogueado,
    this.tokenJwt,
  });

  @override
  State<DocenteEmisionScreen> createState() => _DocenteEmisionScreenState();
}

class _DocenteEmisionScreenState extends State<DocenteEmisionScreen> {
  List<dynamic> asignacionesDocente = [];
  bool _isLoadingOptions = true;
  String selectedType = 'ABSENCE'; 
  TimeOfDay? selectedArrivalTime; 
  List<dynamic> horariosDisponiblesParaAsignacion = [];
  int? selectedScheduleId;
  int? selectedSubjectId; 
  int? selectedCourseId; 
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarOpcionesDocente();
  }

  Future<void> _cargarOpcionesDocente() async {
    try {
      final url = Uri.parse('http://localhost:3000/api/early-notices/options');

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
          asignacionesDocente = data['assignments'] ?? [];
          _isLoadingOptions = false;
        });
      } else {
        throw Exception('No se pudieron cargar las asignaciones');
      }
    } catch (e) {
      print('Error cargando opciones: $e');
      setState(() => _isLoadingOptions = false);
    }
  }

  String get _nombreDocenteCompleto {
    final nombre = widget.usuarioLogueado['firstName'] ?? 'Docente';
    final apellido = widget.usuarioLogueado['lastName'] ?? '';
    return 'Prof. $nombre $apellido';
  }

  String get _selectedSubjectName {
    if (selectedSubjectId == null) return '';
    final item = asignacionesDocente.firstWhere(
      (a) => a['id'] == selectedSubjectId, 
      orElse: () => null,
    );
    return item != null ? (item['subject']?['nombre'] ?? '') : '';
  }

  String get _selectedCourseName {
    if (selectedCourseId == null) return '';
    final item = asignacionesDocente.firstWhere(
      (a) => (a['course']?['id'] ?? a['courseId']) == selectedCourseId, 
      orElse: () => null,
    );
    return item != null ? (item['course']?['nombre'] ?? '') : '';
  }

  // 🛡️ Conversor robusto para traducir el texto del día a número (1=Lunes ... 7=Domingo)
  int? _obtenerWeekdayDesdeTexto(String diaTexto) {
    final normalizado = diaTexto.toLowerCase().trim();
    if (normalizado.contains('lunes') || normalizado.contains('monday')) return DateTime.monday;
    if (normalizado.contains('martes') || normalizado.contains('tuesday')) return DateTime.tuesday;
    if (normalizado.contains('miér') || normalizado.contains('mier') || normalizado.contains('wednesday')) return DateTime.wednesday;
    if (normalizado.contains('jueves') || normalizado.contains('thursday')) return DateTime.thursday;
    if (normalizado.contains('viernes') || normalizado.contains('friday')) return DateTime.friday;
    if (normalizado.contains('sáb') || normalizado.contains('sab') || normalizado.contains('saturday')) return DateTime.saturday;
    if (normalizado.contains('domingo') || normalizado.contains('sunday')) return DateTime.sunday;
    return null;
  }

  String _generarTextoMensaje() {
    if (selectedSubjectId == null ||
        selectedCourseId == null ||
        selectedDate == null ||
        selectedTime == null) {
      return 'Complete todos los desplegables, fecha y horario para generar el aviso automático.';
    }

    final fechaStr = '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}';
    final horaClaseStr = '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')} hs';

    if (selectedType == 'LATE_ARRIVAL') {
      final horaLlegadaStr = selectedArrivalTime != null 
          ? '${selectedArrivalTime!.hour.toString().padLeft(2, '0')}:${selectedArrivalTime!.minute.toString().padLeft(2, '0')} hs'
          : 'horario a confirmar';
      
      return 'El/La docente $_nombreDocenteCompleto informa que ingresará tarde (estimado a las $horaLlegadaStr) para la cátedra de "$_selectedSubjectName" '
          '($_selectedCourseName) el día $fechaStr por razones de fuerza mayor.';
    } else {
      return 'El/La docente $_nombreDocenteCompleto informa su inasistencia para la cátedra de "$_selectedSubjectName" '
          '($_selectedCourseName) el día $fechaStr a las $horaClaseStr por razones de fuerza mayor.';
    }
  }

  bool get _formularioValido =>
      selectedSubjectId != null &&
      selectedCourseId != null &&
      selectedDate != null &&
      selectedTime != null &&
      selectedScheduleId != null;

  Future<void> _publicarAusenciaEnBackend() async {
    if (!_formularioValido) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://localhost:3000/api/early-notices'); 
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.tokenJwt ?? widget.usuarioLogueado['token']}',
        },
        body: jsonEncode({
          'type': selectedType,
          'reason': _generarTextoMensaje(),
          'classDate': selectedDate?.toIso8601String().split('T')[0],
          'teacherSubjectId': selectedSubjectId,
          'courseId': selectedCourseId,          
          'scheduleId': selectedScheduleId,      
          'estimatedArrivalTime': selectedType == 'LATE_ARRIVAL' && selectedArrivalTime != null
           ? '${selectedArrivalTime!.hour.toString().padLeft(2, '0')}:${selectedArrivalTime!.minute.toString().padLeft(2, '0管理局'.substring(0, 5))}' // formato seguro HH:mm
           : null,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        widget.onAvisoPublicado();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aviso emitido, sincronizado y notificado al curso.'),
            backgroundColor: Color.fromARGB(255, 210, 126, 0),
            behavior: SnackBarBehavior.floating,
          ),
        );

        setState(() {
          selectedSubjectId = null;
          selectedCourseId = null;
          selectedDate = null;
          selectedTime = null;
          selectedScheduleId = null;
          selectedArrivalTime = null;
          horariosDisponiblesParaAsignacion = [];
        });
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Error del servidor: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al conectar con el servidor: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingOptions) {
      return Scaffold(
        appBar: AppBar(title: const Text('Espacio Docente')),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFF50E11))), // [MODIFICACIÓN]: Color primario (#F50E11)
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF50E11).withOpacity(0.15), // [MODIFICACIÓN]: Primario con opacidad
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Color(0xFFF50E11), size: 20), // [MODIFICACIÓN]: Ícono primario
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
                    color: Color(0xFFF50E11), // [MODIFICACIÓN]: Texto superior primario
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Emitir Aviso Temprano',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto secundario oscuro
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
            Container( // Contenedor de datos del docente
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white, // [MODIFICACIÓN]: Fondo blanco para tarjeta
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)), // [MODIFICACIÓN]: Borde neutral claro
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: Color(0xFF0D6EFD)), // [MODIFICACIÓN]: Ícono terciario (#0D6EFD)
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Docente responsable', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)), // [MODIFICACIÓN]: Texto auxiliar legible
                      const SizedBox(height: 2),
                      Text(_nombreDocenteCompleto, style: const TextStyle(color: Color(0xFF0F120F), fontWeight: FontWeight.bold, fontSize: 14)), // [MODIFICACIÓN]: Texto secundario oscuro
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'ABSENCE',
                  label: Text('Inasistencia Total'),
                  icon: Icon(Icons.cancel_outlined, size: 18),
                ),
                ButtonSegment(
                  value: 'LATE_ARRIVAL',
                  label: Text('Llegada Tarde'),
                  icon: Icon(Icons.timer_outlined, size: 18),
                ),
              ],
              selected: {selectedType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  selectedType = newSelection.first;
                });
              },
              style: ButtonStyle( // SegmentedButton (Inasistencia Total / Llegada Tarde)
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFF50E11).withOpacity(0.15); // [MODIFICACIÓN]: Fondo activo primario suave
                  }
                  return Colors.white; // [MODIFICACIÓN]: Fondo inactivo blanco
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFF50E11); // [MODIFICACIÓN]: Texto activo primario (#F50E11)
                  }
                  return const Color(0xFF64748B); // [MODIFICACIÓN]: Texto inactivo gris
                }),
              ),
            ),
            const SizedBox(height: 14),

            // 1. Dropdown de Materia y Curso
            DropdownButtonFormField<int>(
              dropdownColor: Colors.white, // [MODIFICACIÓN]: Menú desplegable blanco
              decoration: const InputDecoration(
                labelText: 'Materia y Curso',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              value: selectedSubjectId,
              items: asignacionesDocente.map((a) {
                final relationId = a['id']; 
                final subName = a['subject']?['nombre'] ?? 'Materia';
                final courseName = a['course']?['nombre'] ?? 'Curso';
                return DropdownMenuItem<int>(
                  value: relationId,
                  child: Text('$subName — Curso: $courseName'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedSubjectId = val;
                  final asignacionElegida = asignacionesDocente.firstWhere(
                    (a) => a['id'] == val,
                    orElse: () => null,
                  );

                  if (asignacionElegida != null) {
                    selectedCourseId = asignacionElegida['course']?['id'] ?? asignacionElegida['courseId'];
                    horariosDisponiblesParaAsignacion = asignacionElegida['schedules'] ?? [];
                  } else {
                    selectedCourseId = null;
                    horariosDisponiblesParaAsignacion = [];
                  }
                  selectedScheduleId = null; 
                  selectedDate = null;
                  selectedTime = null;
                  selectedArrivalTime = null;
                });
              },
            ),
            const SizedBox(height: 14),

            // 2. Dropdown de Bloque Horario / Día de Cátedra
            DropdownButtonFormField<int>(
              dropdownColor: Colors.white, // [MODIFICACIÓN]: Menú flotante claro
              decoration: const InputDecoration(
                labelText: 'Bloque Horario / Día de Cátedra',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
              value: selectedScheduleId,
              items: horariosDisponiblesParaAsignacion.map((sch) {
                final dia = sch['day'] ?? '';
                final inicio = sch['startTime'] ?? '';
                final fin = sch['endTime'] ?? '';
                return DropdownMenuItem<int>(
                  value: sch['id'],
                  child: Text('$dia de $inicio a $fin hs'),
                );
              }).toList(),
              onChanged: selectedCourseId == null ? null : (val) {
                setState(() {
                  selectedScheduleId = val;
                  final schSeleccionado = horariosDisponiblesParaAsignacion.firstWhere((s) => s['id'] == val, orElse: () => null);
                  if (schSeleccionado != null) {
                    final partesHora = (schSeleccionado['startTime'] ?? '08:00').split(':');
                    selectedTime = TimeOfDay(hour: int.parse(partesHora[0]), minute: int.parse(partesHora[1]));
                    selectedDate = null; 
                  }
                });
              },
            ),
            const SizedBox(height: 14),

            // 3. Botón Calendario Seguro (Abre fluido en Web y Móvil, y valida el día de la cátedra al seleccionar)
            OutlinedButton.icon( // Calendario y Hora Estimada
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white, // [MODIFICACIÓN]: Fondo blanco
                side: BorderSide(
                  color: selectedScheduleId != null ? const Color(0xFFF50E11) : const Color(0xFFCBD5E1), // [MODIFICACIÓN]: Borde activo primario (#F50E11)
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              onPressed: selectedScheduleId == null ? null : () async {
                final schSeleccionado = horariosDisponiblesParaAsignacion.firstWhere(
                  (s) => s['id'] == selectedScheduleId,
                  orElse: () => null,
                );

                final diaCatedra = schSeleccionado?['day'] ?? 'clase';
                final int? targetWeekday = _obtenerWeekdayDesdeTexto(diaCatedra);

                // Calendario estándar fluido sin bloqueos de renderizado web
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  helpText: 'Seleccione fecha de clase ($diaCatedra)',
                  confirmText: 'CONFIRMAR',
                  cancelText: 'CANCELAR',
                );

                if (picked != null) {
                  // 🛡️ Validación posterior post-selección para asegurar que sea el día correcto de la cátedra
                  if (targetWeekday != null && picked.weekday != targetWeekday) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('La fecha seleccionada no corresponde a un día $diaCatedra. Por favor elija un día válido.'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                }
              },
              // Asegurar color de iconos y textos internos a tonos oscuros/primarios:
              icon: const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFFF50E11)), // [MODIFICACIÓN]: Ícono primario
              label: Text(
                selectedDate == null
                    ? (selectedScheduleId == null 
                        ? 'Primero seleccione un bloque horario' 
                        : 'Seleccionar Fecha en el Calendario')
                    : 'Fecha de clase: ${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}',
                style: const TextStyle(color: Color(0xFF0F120F), fontWeight: FontWeight.bold, fontSize: 13.5), // [MODIFICACIÓN]: Texto secundario oscuro
              ),
            ),
            const SizedBox(height: 14),

            // 4. Selector de Hora para Llegada Tarde
            if (selectedType == 'LATE_ARRIVAL') ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white, // [MODIFICACIÓN]: Fondo blanco para modo claro
                  side: const BorderSide(color: Color(0xFFF50E11), width: 1.5), // [MODIFICACIÓN]: Borde primario (#F50E11)
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                onPressed: selectedScheduleId == null ? null : () async {
                  final schSeleccionado = horariosDisponiblesParaAsignacion.firstWhere(
                    (s) => s['id'] == selectedScheduleId, 
                    orElse: () => null,
                  );

                  if (schSeleccionado == null) return;

                  final partesInicio = (schSeleccionado['startTime'] ?? '08:00').split(':');
                  final partesFin = (schSeleccionado['endTime'] ?? '12:00').split(':');
                  
                  final int minInicio = int.parse(partesInicio[0]) * 60 + int.parse(partesInicio[1]);
                  final int minFin = int.parse(partesFin[0]) * 60 + int.parse(partesFin[1]);

                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: int.parse(partesInicio[0]), minute: int.parse(partesInicio[1])),
                  );

                  if (picked != null) {
                    final int minSeleccionados = picked.hour * 60 + picked.minute;

                    if (minSeleccionados < minInicio || minSeleccionados > minFin) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('La hora debe estar entre ${schSeleccionado['startTime']} y ${schSeleccionado['endTime']} hs'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      setState(() => selectedArrivalTime = picked);
                    }
                  }
                },
                icon: const Icon(Icons.alarm_add_rounded, size: 20, color: Color(0xFFF50E11)), // [MODIFICACIÓN]: Ícono primario (#F50E11)
                label: Text(
                  selectedArrivalTime == null
                      ? 'Seleccionar Hora Estimada de Llegada'
                      : 'Llegada estimada a las: ${selectedArrivalTime!.hour.toString().padLeft(2, '0')}:${selectedArrivalTime!.minute.toString().padLeft(2, '0')} hs',
                  style: const TextStyle(color: Color(0xFF0F120F), fontWeight: FontWeight.bold, fontSize: 13.5), // [MODIFICACIÓN]: Texto secundario oscuro legible
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Contenedor de Mensaje Preescrito Oficial
            Container( 
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: Colors.white, // [MODIFICACIÓN]: Fondo blanco
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _formularioValido
                      ? const Color(0xFFF50E11).withOpacity(0.5) // [MODIFICACIÓN]: Borde primario cuando es válido
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MENSAJE PREESCRITO OFICIAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF50E11), // [MODIFICACIÓN]: Título primario (#F50E11)
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _generarTextoMensaje(),
                    style: TextStyle(
                      color: _formularioValido ? const Color(0xFF0F120F) : const Color(0xFF64748B), // [MODIFICACIÓN]: Contraste claro optimizado
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón Principal de Envío (ElevatedButton)  
            ElevatedButton.icon( 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF50E11), // [MODIFICACIÓN]: Fondo primario (#F50E11)
                foregroundColor: Colors.white, // [MODIFICACIÓN]: Texto blanco
                elevation: 0,
                disabledBackgroundColor: const Color(0xFFE2E8F0), // [MODIFICACIÓN]: Deshabilitado neutro claro
                disabledForegroundColor: const Color(0xFF94A3B8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: (_formularioValido && !_isLoading) ? _publicarAusenciaEnBackend : null,
              icon: _isLoading 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) // [MODIFICACIÓN]: Spinner blanco sobre botón rojo
                : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _isLoading ? 'Enviando al sistema...' : 'Emitir Aviso Temprano',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}