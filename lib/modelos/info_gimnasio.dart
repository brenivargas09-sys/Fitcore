/// Informaci??n general del gimnasio Ciclic Studio.
class InfoGimnasio {
  const InfoGimnasio({
    required this.id,
    this.nombre = 'Ciclic Studio',
    this.descripcion = '',
    this.direccion = '',
    this.telefono = '',
    this.horariosAtencion = '',
    this.servicios = '',
    this.imagenUrl = '',
  });

  final String id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final String telefono;
  final String horariosAtencion;
  final String servicios;
  final String imagenUrl;

  factory InfoGimnasio.desdeMapa(Map<String, dynamic> mapa) {
    return InfoGimnasio(
      id: mapa['id']?.toString() ?? '',
      nombre: (mapa['nombre'] as String?) ?? 'Ciclic Studio',
      descripcion: (mapa['descripcion'] as String?) ?? '',
      direccion: (mapa['direccion'] as String?) ?? '',
      telefono: (mapa['telefono'] as String?) ?? '',
      horariosAtencion: (mapa['horarios_atencion'] as String?) ?? '',
      servicios: (mapa['servicios'] as String?) ?? '',
      imagenUrl: (mapa['imagen_url'] as String?) ?? '',
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'telefono': telefono,
      'horarios_atencion': horariosAtencion,
      'servicios': servicios,
      'imagen_url': imagenUrl,
    };
  }

  InfoGimnasio copyWith({
    String? nombre,
    String? descripcion,
    String? direccion,
    String? telefono,
    String? horariosAtencion,
    String? servicios,
    String? imagenUrl,
  }) {
    return InfoGimnasio(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      horariosAtencion: horariosAtencion ?? this.horariosAtencion,
      servicios: servicios ?? this.servicios,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }
}
