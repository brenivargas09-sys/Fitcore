/// Configuracion de conexion con Supabase.
///
/// Tienes dos formas de entregar las claves:
///
/// 1. Pegandolas directamente aqui abajo (lo mas rapido para desarrollo).
/// 2. Al compilar:
///    flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co ^
///                --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// Si no hay claves, FitCore arranca en modo demo con datos locales
/// (usuario admin@fitcore.com / admin123) para que puedas probar el login
/// y el panel sin backend.
class ConfigSupabase {
  /// Project URL de Supabase. Se inyecta en tiempo de compilacion con:
  ///   flutter build apk --dart-define=SUPABASE_URL=https://xxx.supabase.co
  ///
  /// No se escriben credenciales en el codigo fuente: el pipeline CI/CD las
  /// toma de los secretos del repositorio y las pasa por --dart-define.
  static const String _urlDirecta = '';

  /// Anon public key de Supabase (tambien via --dart-define).
  static const String _claveDirecta = '';

  static const String _urlDefine =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static const String _claveDefine =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static String get url => _urlDirecta.isNotEmpty ? _urlDirecta : _urlDefine;

  static String get anonKey =>
      _claveDirecta.isNotEmpty ? _claveDirecta : _claveDefine;

  /// Fuerza el modo demo (datos locales) aunque haya claves configuradas.
  ///
  /// Se usa en pruebas automaticas y demostraciones sin red.
  static bool forzarDemo = false;

  /// True cuando hay claves validas y se puede usar Supabase.
  static bool get configurado =>
      !forzarDemo && url.isNotEmpty && anonKey.isNotEmpty;
}
