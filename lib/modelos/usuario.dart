/// Roles disponibles dentro de FitCore.
enum Rol {
  admin('admin', 'Administrador'),
  coach('coach', 'Entrenador'),
  socio('socio', 'Socio');

  const Rol(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;

  /// Nombre con el que se muestra este rol en la pantalla de acceso.
  String get etiquetaAcceso {
    switch (this) {
      case Rol.admin:
        return 'Administrador';
      case Rol.coach:
        return 'Instructor';
      case Rol.socio:
        return 'Cliente';
    }
  }

  static Rol desde(String? valor) {
    return Rol.values.firstWhere(
      (r) => r.valor == valor,
      orElse: () => Rol.socio,
    );
  }
}

/// Persona registrada en el gimnasio.
class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    this.telefono = '',
    this.rol = Rol.socio,
    this.activo = true,
    this.especialidad,
    this.fechaRegistro,
  });

  final String id;
  final String nombre;
  final String apellidos;
  final String correo;
  final String telefono;
  final Rol rol;
  final bool activo;
  final String? especialidad;
  final DateTime? fechaRegistro;

  String get nombreCompleto => '$nombre $apellidos'.trim();

  String get iniciales {
    final n = nombre.isNotEmpty ? nombre[0] : '';
    final a = apellidos.isNotEmpty ? apellidos[0] : '';
    return '$n$a'.toUpperCase();
  }

  factory Usuario.desdeMapa(Map<String, dynamic> mapa) {
    return Usuario(
      id: mapa['id']?.toString() ?? '',
      nombre: (mapa['nombre'] as String?) ?? '',
      apellidos: (mapa['apellidos'] as String?) ?? '',
      correo: (mapa['correo'] as String?) ?? '',
      telefono: (mapa['telefono'] as String?) ?? '',
      rol: Rol.desde(mapa['rol'] as String?),
      activo: (mapa['activo'] as bool?) ?? true,
      especialidad: mapa['especialidad'] as String?,
      fechaRegistro: DateTime.tryParse(
        (mapa['fecha_registro'] as String?) ?? '',
      ),
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'rol': rol.valor,
      'activo': activo,
      'especialidad': especialidad,
      'fecha_registro': fechaRegistro?.toIso8601String(),
    };
  }

  Usuario copyWith({
    String? nombre,
    String? apellidos,
    String? correo,
    String? telefono,
    Rol? rol,
    bool? activo,
    String? especialidad,
  }) {
    return Usuario(
      id: id,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      especialidad: especialidad ?? this.especialidad,
      fechaRegistro: fechaRegistro,
    );
  }
}
