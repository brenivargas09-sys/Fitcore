import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config_supabase.dart';
import '../core/error_fitcore.dart';
import '../modelos/usuario.dart';
import 'demo_db.dart';

/// Acceso a los usuarios del gimnasio.
class UsuariosRepo {
  UsuariosRepo._();
  static final UsuariosRepo instancia = UsuariosRepo._();

  SupabaseClient get _db => Supabase.instance.client;

  Future<List<Usuario>> listar() async {
    if (!ConfigSupabase.configurado) {
      return List<Usuario>.from(DemoDB.instancia.usuarios);
    }
    try {
      final filas = await _db.from('usuarios').select().order('nombre');
      return filas.map((f) => Usuario.desdeMapa(Map<String, dynamic>.from(f))).toList();
    } catch (_) {
      throw ErrorFitCore('No se pudieron cargar los usuarios.');
    }
  }

  Future<List<Usuario>> listarPorRol(Rol rol) async {
    final todos = await listar();
    return todos.where((u) => u.rol == rol).toList();
  }

  /// Crea un socio/entrenador en el panel (sin cuenta de acceso en Supabase).
  Future<Usuario> crear({
    required String nombre,
    required String apellidos,
    required String correo,
    required String telefono,
    required Rol rol,
    String? especialidad,
    String? clave,
  }) async {
    if (!ConfigSupabase.configurado) {
      final db = DemoDB.instancia;
      final usuario = Usuario(
        id: db.nuevoId(rol.valor),
        nombre: nombre.trim(),
        apellidos: apellidos.trim(),
        correo: correo.trim(),
        telefono: telefono.trim(),
        rol: rol,
        especialidad: especialidad,
        fechaRegistro: DateTime.now(),
      );
      db.usuarios.add(usuario);
      if (clave != null && clave.isNotEmpty) db.claves[usuario.id] = clave;
      return usuario;
    }

    try {
      final fila = await _db
          .from('usuarios')
          .insert({
            'nombre': nombre.trim(),
            'apellidos': apellidos.trim(),
            'correo': correo.trim(),
            'telefono': telefono.trim(),
            'rol': rol.valor,
            'especialidad': especialidad,
            'activo': true,
          })
          .select()
          .single();
      return Usuario.desdeMapa(Map<String, dynamic>.from(fila));
    } catch (_) {
      throw ErrorFitCore('No se pudo crear el usuario.');
    }
  }

  Future<void> actualizar(Usuario usuario) async {
    if (!ConfigSupabase.configurado) {
      final db = DemoDB.instancia;
      final i = db.usuarios.indexWhere((u) => u.id == usuario.id);
      if (i != -1) db.usuarios[i] = usuario;
      return;
    }
    try {
      await _db.from('usuarios').update({
        'nombre': usuario.nombre,
        'apellidos': usuario.apellidos,
        'correo': usuario.correo,
        'telefono': usuario.telefono,
        'rol': usuario.rol.valor,
        'especialidad': usuario.especialidad,
        'activo': usuario.activo,
      }).eq('id', usuario.id);
    } catch (_) {
      throw ErrorFitCore('No se pudo actualizar el usuario.');
    }
  }

  Future<void> activar(String id, bool activo) async {
    if (!ConfigSupabase.configurado) {
      final db = DemoDB.instancia;
      final i = db.usuarios.indexWhere((u) => u.id == id);
      if (i != -1) db.usuarios[i] = db.usuarios[i].copyWith(activo: activo);
      return;
    }
    try {
      await _db.from('usuarios').update({'activo': activo}).eq('id', id);
    } catch (_) {
      throw ErrorFitCore('No se pudo cambiar el estado del usuario.');
    }
  }

  Future<void> cambiarRol(String id, Rol rol) async {
    if (!ConfigSupabase.configurado) {
      final db = DemoDB.instancia;
      final i = db.usuarios.indexWhere((u) => u.id == id);
      if (i != -1) db.usuarios[i] = db.usuarios[i].copyWith(rol: rol);
      return;
    }
    try {
      await _db.from('usuarios').update({'rol': rol.valor}).eq('id', id);
    } catch (_) {
      throw ErrorFitCore('No se pudo cambiar el rol.');
    }
  }

  Future<void> eliminar(String id) async {
    if (!ConfigSupabase.configurado) {
      final db = DemoDB.instancia;
      db.usuarios.removeWhere((u) => u.id == id);
      db.claves.remove(id);
      return;
    }
    try {
      await _db.from('usuarios').delete().eq('id', id);
    } catch (_) {
      throw ErrorFitCore('No se pudo eliminar el usuario.');
    }
  }
}
