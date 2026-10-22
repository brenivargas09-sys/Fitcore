import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config_supabase.dart';
import '../core/error_fitcore.dart';
import '../modelos/usuario.dart';
import 'demo_db.dart';

/// Servicio de autenticacion contra Supabase (email + contrasena).
///
/// Si Supabase no esta configurado, trabaja contra la base demo en memoria,
/// de modo que el login y el panel funcionan igual sin backend.
class AuthServicio {
  AuthServicio._();
  static final AuthServicio instancia = AuthServicio._();

  bool _listo = false;

  bool get usaSupabase => ConfigSupabase.configurado;

  /// True cuando Supabase quedo inicializado y se puede usar.
  bool get conectado => usaSupabase && _listo;

  SupabaseClient get _cliente {
    if (!_listo) {
      throw ErrorFitCore(
        'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
      );
    }
    return Supabase.instance.client;
  }

  Future<void> inicializar() async {
    if (!usaSupabase) {
      // Sin Supabase cargamos la base demo (admin@fitcore.com / admin123).
      DemoDB.instancia.sembrar();
      return;
    }
    try {
      await Supabase.initialize(
        url: ConfigSupabase.url,
        publishableKey: ConfigSupabase.anonKey,
      );
      _listo = true;
    } catch (_) {
      _listo = false;
      rethrow;
    }
  }

  Future<Usuario> iniciarSesion(
    String correo,
    String clave, {
    Rol? rolEsperado,
  }) async {
    if (!usaSupabase) {
      return _loginDemo(correo, clave, rolEsperado: rolEsperado);
    }

    try {
      final respuesta = await _cliente.auth.signInWithPassword(
        email: correo.trim(),
        password: clave,
      );
      final user = respuesta.user;
      if (user == null) {
        throw ErrorFitCore('Correo o contraseña incorrectos.');
      }
      final usuario = await _perfil(user);
      if (rolEsperado != null && usuario.rol != rolEsperado) {
        await _cliente.auth.signOut();
        throw ErrorFitCore(
          'Esta cuenta no corresponde al rol de ${rolEsperado.etiquetaAcceso}.',
        );
      }
      return usuario;
    } on ErrorFitCore {
      rethrow;
    } on AuthException catch (e) {
      throw ErrorFitCore(_traducir(e));
    } catch (e) {
      throw _errorInesperado(e);
    }
  }

  Future<Usuario> registrar({
    required String nombre,
    required String apellidos,
    required String telefono,
    required String correo,
    required String clave,
    Rol rol = Rol.socio,
  }) async {
    if (!usaSupabase) {
      return _registroDemo(nombre, apellidos, telefono, correo, clave, rol);
    }

    try {
      final respuesta = await _cliente.auth.signUp(
        email: correo.trim(),
        password: clave,
        data: {
          'nombre': nombre.trim(),
          'apellidos': apellidos.trim(),
          'telefono': telefono.trim(),
          'rol': rol.valor,
        },
      );

      if (respuesta.session == null || respuesta.user == null) {
        throw ErrorFitCore(
          'Cuenta creada. Revisa tu correo para confirmarla antes de entrar.',
        );
      }
      return await _perfil(respuesta.user!);
    } on ErrorFitCore {
      rethrow;
    } on AuthException catch (e) {
      throw ErrorFitCore(_traducir(e));
    } catch (e) {
      throw _errorInesperado(e);
    }
  }

  Future<void> cerrarSesion() async {
    if (!usaSupabase) return;
    try {
      await _cliente.auth.signOut();
    } catch (_) {
      // La sesion local se limpia igualmente.
    }
  }

  // --- Supabase -------------------------------------------------------------

  Future<Usuario> _perfil(User user) async {
    try {
      final fila = await _cliente
          .from('usuarios')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      Map<String, dynamic> datos;
      if (fila == null) {
        datos = {
          'id': user.id,
          'nombre': user.userMetadata?['nombre'] ?? '',
          'apellidos': user.userMetadata?['apellidos'] ?? '',
          'telefono': user.userMetadata?['telefono'] ?? '',
          'correo': user.email ?? '',
          'rol': user.userMetadata?['rol'] ?? Rol.socio.valor,
          'activo': true,
          'fecha_registro': user.createdAt,
        };
        await _cliente.from('usuarios').upsert(datos);
      } else {
        datos = Map<String, dynamic>.from(fila);
      }

      final usuario = Usuario.desdeMapa(datos);
      if (!usuario.activo) {
        await _cliente.auth.signOut();
        throw ErrorFitCore(
          'Tu cuenta está desactivada. Contacta al administrador.',
        );
      }
      return usuario;
    } on ErrorFitCore {
      rethrow;
    } on PostgrestException catch (e) {
      throw ErrorFitCore('No se pudo cargar tu perfil. ${_detalle(e)}');
    } catch (e) {
      throw _errorInesperado(e);
    }
  }

  String _detalle(PostgrestException e) {
    final m = e.message.toLowerCase();
    if (e.code == '42501' || m.contains('permission') || m.contains('row-level')) {
      return 'El servidor no autoriza el acceso a tu perfil: revisa las '
          'políticas RLS de la tabla "usuarios".';
    }
    if (m.contains('does not exist') || e.code == '42P01') {
      return 'Falta la tabla "usuarios": ejecuta supabase/esquema.sql en el '
          'SQL Editor de Supabase.';
    }
    return 'Detalle: ${e.message}';
  }

  // --- Modo demo ------------------------------------------------------------

  Usuario _loginDemo(String correo, String clave, {Rol? rolEsperado}) {
    final db = DemoDB.instancia;
    final buscado = correo.trim().toLowerCase();
    final usuario = db.usuarios.cast<Usuario?>().firstWhere(
          (u) => u!.correo.toLowerCase() == buscado,
          orElse: () => null,
        );
    if (usuario == null || db.claves[usuario.id] != clave) {
      throw ErrorFitCore('Correo o contraseña incorrectos.');
    }
    if (!usuario.activo) {
      throw ErrorFitCore('Tu cuenta está desactivada. Contacta al administrador.');
    }
    if (rolEsperado != null && usuario.rol != rolEsperado) {
      throw ErrorFitCore(
        'Esta cuenta no corresponde al rol de ${rolEsperado.etiquetaAcceso}.',
      );
    }
    return usuario;
  }

  Usuario _registroDemo(
    String nombre,
    String apellidos,
    String telefono,
    String correo,
    String clave,
    Rol rol,
  ) {
    final db = DemoDB.instancia;
    final buscado = correo.trim().toLowerCase();
    if (db.usuarios.any((u) => u.correo.toLowerCase() == buscado)) {
      throw ErrorFitCore('Ya existe una cuenta con ese correo.');
    }
    final usuario = Usuario(
      id: db.nuevoId(rol.valor),
      nombre: nombre.trim(),
      apellidos: apellidos.trim(),
      correo: correo.trim(),
      telefono: telefono.trim(),
      rol: rol,
      fechaRegistro: DateTime.now(),
    );
    db.usuarios.add(usuario);
    db.claves[usuario.id] = clave;
    return usuario;
  }

  // --- Traduccion de errores ------------------------------------------------

  String _traducir(AuthException e) {
    final m = e.message.toLowerCase();
    if (_esFalloDeRed(m)) {
      return 'Sin conexión a internet. Revisa tu red e inténtalo de nuevo.';
    }
    if (m.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (m.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de entrar. Revisa tu bandeja.';
    }
    if (m.contains('already registered') || m.contains('already been registered')) {
      return 'Ya existe una cuenta con ese correo electrónico.';
    }
    if (m.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (m.contains('unable to validate email')) {
      return 'El correo no tiene un formato válido.';
    }
    if (m.contains('rate limit') || m.contains('too many')) {
      return 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';
    }
    if (m.contains('signups not allowed')) {
      return 'El registro de cuentas está deshabilitado en el servidor.';
    }
    return 'No se pudo completar la operación. (${e.message})';
  }

  bool _esFalloDeRed(String m) =>
      m.contains('failed to fetch') ||
      m.contains('socketexception') ||
      m.contains('failed host lookup') ||
      m.contains('connection closed') ||
      m.contains('connection reset') ||
      m.contains('connection refused') ||
      m.contains('network is unreachable') ||
      m.contains('clientexception') ||
      m.contains('timed out') ||
      m.contains('timeout');

  ErrorFitCore _errorInesperado(Object e) {
    if (_esFalloDeRed(e.toString().toLowerCase())) {
      return ErrorFitCore(
        'Sin conexión a internet. Revisa tu red e inténtalo de nuevo.',
      );
    }
    debugPrint('FitCore: error no controlado -> $e');
    return ErrorFitCore('Ocurrió un error inesperado. Inténtalo de nuevo.');
  }
}
