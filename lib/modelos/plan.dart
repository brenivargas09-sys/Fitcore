/// Tipo de membresía ofrecido por el gimnasio.
class PlanMembresia {
  const PlanMembresia({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    this.duracionDias = 30,
    this.precio = 0,
    this.condiciones = '',
    this.activo = true,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final int duracionDias;
  final double precio;
  final String condiciones;
  final bool activo;

  factory PlanMembresia.desdeMapa(Map<String, dynamic> mapa) {
    return PlanMembresia(
      id: mapa['id']?.toString() ?? '',
      nombre: (mapa['nombre'] as String?) ?? '',
      descripcion: (mapa['descripcion'] as String?) ?? '',
      duracionDias: (mapa['duracion_dias'] as num?)?.toInt() ?? 30,
      precio: (mapa['precio'] as num?)?.toDouble() ?? 0,
      condiciones: (mapa['condiciones'] as String?) ?? '',
      activo: (mapa['activo'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'duracion_dias': duracionDias,
      'precio': precio,
      'condiciones': condiciones,
      'activo': activo,
    };
  }

  PlanMembresia copyWith({
    String? nombre,
    String? descripcion,
    int? duracionDias,
    double? precio,
    String? condiciones,
    bool? activo,
  }) {
    return PlanMembresia(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      duracionDias: duracionDias ?? this.duracionDias,
      precio: precio ?? this.precio,
      condiciones: condiciones ?? this.condiciones,
      activo: activo ?? this.activo,
    );
  }
}
