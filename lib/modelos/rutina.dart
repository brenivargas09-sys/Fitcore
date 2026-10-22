/// Rutina de entrenamiento asignada por un entrenador.
class Rutina {
  const Rutina({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    this.coachId,
    this.coachNombre = '',
    this.nivel = 'Principiante',
    this.semanas = 4,
    this.activa = true,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final String? coachId;
  final String coachNombre;
  final String nivel;
  final int semanas;
  final bool activa;

  static const List<String> niveles = [
    'Principiante',
    'Intermedio',
    'Avanzado',
  ];

  factory Rutina.desdeMapa(Map<String, dynamic> mapa) {
    return Rutina(
      id: mapa['id']?.toString() ?? '',
      nombre: (mapa['nombre'] as String?) ?? '',
      descripcion: (mapa['descripcion'] as String?) ?? '',
      coachId: mapa['coach_id'] as String?,
      coachNombre: (mapa['coach_nombre'] as String?) ?? '',
      nivel: (mapa['nivel'] as String?) ?? 'Principiante',
      semanas: (mapa['semanas'] as num?)?.toInt() ?? 4,
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
      'nivel': nivel,
      'semanas': semanas,
      'activa': activa,
    };
  }

  Rutina copyWith({
    String? nombre,
    String? descripcion,
    String? coachId,
    String? coachNombre,
    String? nivel,
    int? semanas,
    bool? activa,
  }) {
    return Rutina(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      coachId: coachId ?? this.coachId,
      coachNombre: coachNombre ?? this.coachNombre,
      nivel: nivel ?? this.nivel,
      semanas: semanas ?? this.semanas,
      activa: activa ?? this.activa,
    );
  }
}
