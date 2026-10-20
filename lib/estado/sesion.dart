import 'package:flutter/foundation.dart';

import '../core/error_fitcore.dart';
import '../datos/auth_servicio.dart';
import '../modelos/usuario.dart';

/// Estado global de la sesion, expuesto con Provider.
class Sesion extends ChangeNotifier {
  Sesion._();
  static final Sesion instancia = Sesion._();

  Usuario? _usuario;

  /// Arranca en true: la PuertaAcceso muestra la pantalla de inicio mientras
  /// se restaura la sesion guardada.
  bool _cargando = true;
  String? _error;

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get autenticado => _usuario != null;
  bool get esAdmin => _usuario?.rol == Rol.admin;
  bool get usaSupabase => AuthServicio.instancia.usaSupabase;

  /// Prepara el arranque de la app sin restaurar ninguna sesion previa:
  /// la entrada siempre exige validar las credenciales en el login.
  Future<void> iniciar() async {
    _cargando = true;
    notifyListeners();
    try {
      await AuthServicio.instancia.cerrarSesion();
    } catch (_) {
      // Aunque falle el cierre remoto, la app arranca en el login.
    }
    _usuario = null;
    _cargando = false;
    notifyListeners();
  }

  Future<bool> entrar(String correo, String clave, {Rol? rolEsperado}) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _usuario = await AuthServicio.instancia.iniciarSesion(
        correo,
        clave,
        rolEsperado: rolEsperado,
      );
      _cargando = false;
      notifyListeners();
      return true;
    } on ErrorFitCore catch (e) {
      _error = e.mensaje;
      _cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('FitCore: fallo al iniciar sesión -> $e');
      _error = 'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrar({
    required String nombre,
    required String apellidos,
    required String telefono,
    required String correo,
    required String clave,
    Rol rol = Rol.socio,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _usuario = await AuthServicio.instancia.registrar(
        nombre: nombre,
        apellidos: apellidos,
        telefono: telefono,
        correo: correo,
        clave: clave,
        rol: rol,
      );
      _cargando = false;
      notifyListeners();
      return true;
    } on ErrorFitCore catch (e) {
      _error = e.mensaje;
      _cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('FitCore: fallo al registrar -> $e');
      _error = 'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> salir() async {
    await AuthServicio.instancia.cerrarSesion();
    _usuario = null;
    _error = null;
    notifyListeners();
  }

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
