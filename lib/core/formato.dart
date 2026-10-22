import 'package:intl/intl.dart';

/// Formato corto de las principales utilidades de presentacion.
class Formato {
  Formato._();

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');
  static final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');

  static String fecha(DateTime? valor) => valor == null ? '—' : _fecha.format(valor);

  static String fechaHora(DateTime? valor) =>
      valor == null ? '—' : _fechaHora.format(valor);

  /// Dinero con separador de miles y dos decimales.
  static String dinero(num valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final entero = partes[0];
    final conMiles = entero.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    return '\$$conMiles.${partes[1]}';
  }
}
