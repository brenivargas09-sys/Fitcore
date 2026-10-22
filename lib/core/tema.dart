import 'package:flutter/material.dart';

/// Identidad visual de FitCore.
class TemaFitCore {
  // Azul eléctrico + cian.
  static const Color azul = Color(0xFF2E7BFF);
  static const Color azulOscuro = Color(0xFF1B4FD8);
  static const Color cian = Color(0xFF22D3EE);

  // Tonos oscuros.
  static const Color carbon = Color(0xFF0A0E14);
  static const Color carbonClaro = Color(0xFF161D29);
  static const Color superficieOscura = Color(0xFF141A24);

  static ThemeData claro() => _base(
        ColorScheme.fromSeed(
          seedColor: azul,
          brightness: Brightness.light,
        ),
      );

  static ThemeData oscuro() => _base(
        ColorScheme.fromSeed(
          seedColor: azul,
          brightness: Brightness.dark,
        ).copyWith(
          primary: azul,
          secondary: cian,
          surface: superficieOscura,
          onSurface: const Color(0xFFE7ECF3),
        ),
      );

  static ThemeData _base(ColorScheme esquema) {
    final esOscuro = esquema.brightness == Brightness.dark;
    final fondo = esOscuro ? carbon : const Color(0xFFF5F6F8);
    final superficie = esOscuro ? superficieOscura : Colors.white;

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fondo,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: esOscuro ? carbonClaro : superficie,
        foregroundColor: esquema.onSurface,
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(
            color: esOscuro
                ? Colors.white.withValues(alpha: 0.07)
                : esquema.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: esquema.onSurface,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: esOscuro ? carbonClaro : superficie,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: esOscuro
                ? Colors.white.withValues(alpha: 0.07)
                : esquema.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esOscuro ? carbon : superficie,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _borde(esquema),
        enabledBorder: _borde(esquema),
        focusedBorder: _borde(esquema, color: azul, ancho: 2),
        errorBorder: _borde(esquema, color: esquema.error),
        focusedErrorBorder: _borde(esquema, color: esquema.error, ancho: 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: superficie,
        indicatorColor: azul.withValues(alpha: 0.18),
        selectedIconTheme: const IconThemeData(color: azul),
        selectedLabelTextStyle: const TextStyle(
          color: azul,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: esOscuro
            ? Colors.white.withValues(alpha: 0.08)
            : esquema.outlineVariant.withValues(alpha: 0.5),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static OutlineInputBorder _borde(
    ColorScheme esquema, {
    Color? color,
    double ancho = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: color ??
            (esquema.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.12)
                : esquema.outlineVariant),
        width: ancho,
      ),
    );
  }
}
