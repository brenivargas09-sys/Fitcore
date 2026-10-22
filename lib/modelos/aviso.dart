/// Aviso o novedad publicado por el administrador.
class Aviso {
  const Aviso({
    required this.id,
    required this.titulo,
    this.contenido = '',
    this.fechaPublicacion,
    this.activo = true,
    this.importante = false,
  });

  final String id;
  final String titulo;
  final String contenido;
  final DateTime? fechaPublicacion;
  final bool activo;
  final bool importante;

  factory Aviso.desdeMapa(Map<String, dynamic> mapa) {
    return Aviso(
      id: mapa['id']?.toString() ?? '',
      titulo: (mapa['titulo'] as String?) ?? '',
      contenido: (mapa['contenido'] as String?) ?? '',
      fechaPublicacion: DateTime.tryParse(
        (mapa['fecha_publicacion'] as String?) ?? '',
      ),
      activo: (mapa['activo'] as bool?) ?? true,
      importante: (mapa['importante'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'titulo': titulo,
      'contenido': contenido,
      'fecha_publicacion': fechaPublicacion?.toIso8601String(),
      'activo': activo,
      'importante': importante,
    };
  }

  Aviso copyWith({
    String? titulo,
    String? contenido,
    DateTime? fechaPublicacion,
    bool? activo,
    bool? importante,
  }) {
    return Aviso(
      id: id,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
      activo: activo ?? this.activo,
      importante: importante ?? this.importante,
    );
  }
}
