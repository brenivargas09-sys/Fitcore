/// Plan contratado por un socio.
class Membresia {
  const Membresia({
    required this.id,
    required this.socioId,
    this.socioNombre = '',
    this.plan = 'Mensual',
    this.precio = 0,
    this.fechaInicio,
    this.fechaFin,
    this.activa = true,
  });

  final String id;
  final String socioId;
  final String socioNombre;
  final String plan;
  final double precio;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final bool activa;

  static const List<String> planes = [
    'Mensual',
    'Trimestral',
    'Semestral',
    'Anual',
  ];

  bool get vencida {
    if (fechaFin == null) return false;
    return fechaFin!.isBefore(DateTime.now());
  }

  factory Membresia.desdeMapa(Map<String, dynamic> mapa) {
    return Membresia(
      id: mapa['id']?.toString() ?? '',
      socioId: mapa['socio_id']?.toString() ?? '',
      socioNombre: (mapa['socio_nombre'] as String?) ?? '',
      plan: (mapa['plan'] as String?) ?? 'Mensual',
      precio: (mapa['precio'] as num?)?.toDouble() ?? 0,
      fechaInicio: DateTime.tryParse((mapa['fecha_inicio'] as String?) ?? ''),
      fechaFin: DateTime.tryParse((mapa['fecha_fin'] as String?) ?? ''),
      activa: (mapa['activa'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'socio_id': socioId,
      'socio_nombre': socioNombre,
      'plan': plan,
      'precio': precio,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'activa': activa,
    };
  }

  Membresia copyWith({
    String? socioId,
    String? socioNombre,
    String? plan,
    double? precio,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? activa,
  }) {
    return Membresia(
      id: id,
      socioId: socioId ?? this.socioId,
      socioNombre: socioNombre ?? this.socioNombre,
      plan: plan ?? this.plan,
      precio: precio ?? this.precio,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      activa: activa ?? this.activa,
    );
  }
}
