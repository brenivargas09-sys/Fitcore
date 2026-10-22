/// Registro de pago de un socio.
class Pago {
  const Pago({
    required this.id,
    required this.socioId,
    this.socioNombre = '',
    this.concepto = 'Mensualidad',
    this.monto = 0,
    this.metodo = 'Efectivo',
    this.fecha,
    this.pagado = true,
  });

  final String id;
  final String socioId;
  final String socioNombre;
  final String concepto;
  final double monto;
  final String metodo;
  final DateTime? fecha;
  final bool pagado;

  static const List<String> metodos = [
    'Efectivo',
    'Tarjeta',
    'Transferencia',
  ];

  factory Pago.desdeMapa(Map<String, dynamic> mapa) {
    return Pago(
      id: mapa['id']?.toString() ?? '',
      socioId: mapa['socio_id']?.toString() ?? '',
      socioNombre: (mapa['socio_nombre'] as String?) ?? '',
      concepto: (mapa['concepto'] as String?) ?? 'Mensualidad',
      monto: (mapa['monto'] as num?)?.toDouble() ?? 0,
      metodo: (mapa['metodo'] as String?) ?? 'Efectivo',
      fecha: DateTime.tryParse((mapa['fecha'] as String?) ?? ''),
      pagado: (mapa['pagado'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'socio_id': socioId,
      'socio_nombre': socioNombre,
      'concepto': concepto,
      'monto': monto,
      'metodo': metodo,
      'fecha': fecha?.toIso8601String(),
      'pagado': pagado,
    };
  }
}
