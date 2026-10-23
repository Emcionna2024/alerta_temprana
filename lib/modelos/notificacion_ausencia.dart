class NotificacionAusencia {
  final String id;
  final String docente;
  final String materia;
  final String curso;
  final String fecha;
  final String horario;
  final String mensaje;
  final DateTime fechaEmision;
  bool recibida;

  NotificacionAusencia({
    required this.id,
    required this.docente,
    required this.materia,
    required this.curso,
    required this.fecha,
    required this.horario,
    required this.mensaje,
    required this.fechaEmision,
    this.recibida = false,
  });
}

class RepositorioNotificaciones {
  static final List<NotificacionAusencia> lista = [
    NotificacionAusencia(
      id: 'demo-1',
      docente: 'Prof. Carlos Benítez',
      materia: 'Programación I',
      curso: '1° Año A',
      fecha: '20/10/2026',
      horario: '18:00 hs',
      mensaje:
          'AVISO OFICIAL DE AUSENCIA:\n\nEl/La docente Prof. Carlos Benítez informa que no asistirá a la clase de "Programación I" correspondiente al curso 1° Año A programada para el día 20/10/2026 a las 18:00 hs por razones de fuerza mayor.',
      fechaEmision: DateTime.now().subtract(const Duration(hours: 2)),
      recibida: false,
    ),
  ];
}