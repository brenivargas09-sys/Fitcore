/// Clase dirigida del gimnasio (aerobics, spinning, zumba, etc.).
class Clase {
  const Clase({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    this.coachId,
    this.coachNombre = '',
    this.diaSemana = 1,
    this.hora = '18:00',
    this.duracionMin = 60,
    this.cupoMax = 20,
    this.sala = '',
    this.activa = true,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final String? coachId;
  final String coachNombre;

  /// 1 = lunes ... 7 = domingo.
  final int diaSemana;
  final String hora;
  final int duracionMin;
  final int cupoMax;
  final String sala;
  final bool activa;

  static const List<String> dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  String get diaEtiqueta =>
      diaSemana >= 1 && diaSemana <= 7 ? dias[diaSemana - 1] : '—';

  String get horario => '$diaEtiqueta · $hora ($duracionMin min)';

  factory Clase.desdeMapa(Map<String, dynamic> mapa) {
    return Clase(
      id: mapa['id']?.toString() ?? '',
      nombre: (mapa['nombre'] as String?) ?? '',
      descripcion: (mapa['descripcion'] as String?) ?? '',
      coachId: mapa['coach_id'] as String?,
      coachNombre: (mapa['coach_nombre'] as String?) ?? '',
      diaSemana: (mapa['dia_semana'] as num?)?.toInt() ?? 1,
      hora: (mapa['hora'] as String?) ?? '18:00',
      duracionMin: (mapa['duracion_min'] as num?)?.toInt() ?? 60,
      cupoMax: (mapa['cupo_max'] as num?)?.toInt() ?? 20,
      sala: (mapa['sala'] as String?) ?? '',
      activa: (mapa['activa'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'coach_id': coachId,
      'coach_nombre': coachNombre,
      'dia_semana': diaSemana,
      'hora': hora,
      'duracion_min': duracionMin,
      'cupo_max': cupoMax,
      'sala': sala,
      'activa': activa,
    };
  }

  Clase copyWith({
    String? nombre,
    String? descripcion,
    String? coachId,
    String? coachNombre,
    int? diaSemana,
    String? hora,
    int? duracionMin,
    int? cupoMax,
    String? sala,
    bool? activa,
  }) {
    return Clase(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      coachId: coachId ?? this.coachId,
      coachNombre: coachNombre ?? this.coachNombre,
      diaSemana: diaSemana ?? this.diaSemana,
      hora: hora ?? this.hora,
      duracionMin: duracionMin ?? this.duracionMin,
      cupoMax: cupoMax ?? this.cupoMax,
      sala: sala ?? this.sala,
      activa: activa ?? this.activa,
    );
  }
}
