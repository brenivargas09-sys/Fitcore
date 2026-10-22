// Verificacion del backend real de FitCore (Supabase).
//
// Comprueba, usando el mismo cliente Supabase que consume la aplicacion, que:
//   1. el servicio de autenticacion responde (health);
//   2. las credenciales del usuario configurado inician sesion y devuelven token;
//   3. la RPC es_admin confirma el rol del usuario;
//   4. las ocho tablas del modelo de datos responden con estado 200;
//   5. la RLS oculta las filas al rol anonimo (sin sesion) y sin apikey la API
//      responde 401.
//
// Uso (Windows PowerShell):
//   $env:SUPABASE_URL="https://TU-PROYECTO.supabase.co"
//   $env:SUPABASE_ANON_KEY="eyJ..."
//   $env:FITCORE_TEST_EMAIL="admin@fitcore.com"
//   $env:FITCORE_TEST_PASSWORD="admin123"
//   dart run tool/verificar_backend.dart
//
// Codigo de salida: 0 si todas las comprobaciones son correctas, 1 si alguna falla.

import 'dart:io';

import 'package:supabase/supabase.dart';

const tablas = <String>[
  'usuarios',
  'clases',
  'rutinas',
  'membresias',
  'pagos',
  'avisos',
  'planes',
  'info_gimnasio',
];

int _fallos = 0;

void _ok(String mensaje) => stdout.writeln('  [OK]   $mensaje');

void _error(String mensaje) {
  _fallos++;
  stdout.writeln('  [FALLA] $mensaje');
}

Future<void> main() async {
  final url = Platform.environment['SUPABASE_URL'] ?? '';
  final anonKey = Platform.environment['SUPABASE_ANON_KEY'] ?? '';
  final email = Platform.environment['FITCORE_TEST_EMAIL'] ?? 'admin@fitcore.com';
  final password = Platform.environment['FITCORE_TEST_PASSWORD'] ?? 'admin123';

  stdout.writeln('FitCore - verificacion del backend Supabase');
  stdout.writeln('  proyecto: ${url.isEmpty ? '(sin configurar)' : url}');

  if (url.isEmpty || anonKey.isEmpty) {
    stderr.writeln(
      'Faltan SUPABASE_URL y/o SUPABASE_ANON_KEY en el entorno.',
    );
    exit(1);
  }

  final cliente = SupabaseClient(url, anonKey);

  stdout.writeln('1) Autenticacion (GoTrue)');
  try {
    final res = await cliente.auth.signInWithPassword(email: email, password: password);
    if (res.user != null) {
      _ok('login correcto: ${res.user!.email} (id ${res.user!.id})');
    } else {
      _error('el login no devolvio usuario');
    }
  } catch (e) {
    _error('login fallido: $e');
  }

  stdout.writeln('2) Rol administrativo (RPC es_admin)');
  try {
    final esAdmin = await cliente.rpc('es_admin');
    if (esAdmin == true) {
      _ok('es_admin = true');
    } else {
      _error('es_admin = $esAdmin (se esperaba true)');
    }
  } catch (e) {
    _error('no se pudo invocar es_admin: $e');
  }

  stdout.writeln('3) Lectura autenticada de las ${tablas.length} tablas');
  for (final tabla in tablas) {
    try {
      final filas = await cliente.from(tabla).select();
      _ok('$tabla -> ${filas.length} fila(s)');
    } catch (e) {
      _error('$tabla -> error: $e');
    }
  }

  stdout.writeln('4) Seguridad: RLS y ausencia de credenciales');
  try {
    final anonimo = SupabaseClient(url, anonKey);
    await anonimo.auth.signOut();
    final filas = await anonimo.from('usuarios').select();
    if (filas.isEmpty) {
      _ok('el rol anonimo no observa filas de usuarios (RLS activa)');
    } else {
      _error('el rol anonimo observo ${filas.length} fila(s) en usuarios');
    }
  } catch (e) {
    _error('no se pudo verificar la RLS: $e');
  }

  stdout.writeln('5) Sin apikey la API responde 401');
  try {
    final sinClave = SupabaseClient(url, '');
    await sinClave.from('usuarios').select();
    _error('la API respondio sin credenciales (se esperaba 401)');
  } catch (e) {
    if (e.toString().contains('401')) {
      _ok('peticion sin apikey rechazada con 401');
    } else {
      _error('error inesperado sin apikey: $e');
    }
  }

  stdout.writeln('');
  if (_fallos == 0) {
    stdout.writeln('RESULTADO: todas las comprobaciones fueron correctas.');
    exit(0);
  }
  stdout.writeln('RESULTADO: $_fallos comprobacion(es) fallaron.');
  exit(1);
}


