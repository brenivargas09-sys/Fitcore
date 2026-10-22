import 'package:flutter/material.dart';

/// Controla el modo claro/oscuro de la aplicacion, expuesto con Provider.
class ControlTema extends ChangeNotifier {
  ControlTema._();
  static final ControlTema instancia = ControlTema._();

  ThemeMode _modo = ThemeMode.system;

  ThemeMode get modo => _modo;

  /// Indica si la interfaz se pinta en oscuro segun el modo actual.
  bool get esOscuro {
    if (_modo != ThemeMode.system) return _modo == ThemeMode.dark;
    final brillo = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brillo == Brightness.dark;
  }

  /// Alterna entre modo claro y modo oscuro.
  void alternar() {
    usar(esOscuro ? ThemeMode.light : ThemeMode.dark);
  }

  void usar(ThemeMode modo) {
    if (_modo == modo) return;
    _modo = modo;
    notifyListeners();
  }
}
