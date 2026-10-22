import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitcore/core/formato.dart';
import 'package:fitcore/estado/sesion.dart';
import 'package:fitcore/main.dart';
import 'package:fitcore/modelos/usuario.dart';

/// Fija un tamano de pantalla realista para probar la interfaz.
void _usarPantalla(WidgetTester tester, Size tamano, {double densidad = 2.0}) {
  tester.view.devicePixelRatio = densidad;
  tester.view.physicalSize = Size(
    tamano.width * densidad,
    tamano.height * densidad,
  );
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _abrirApp(WidgetTester tester, Size tamano) async {
  _usarPantalla(tester, tamano);
  unawaited(Sesion.instancia.iniciar());
  await tester.pumpWidget(const AplicacionFitCore());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 80));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Modelo y formato', () {
    test('Rol.desde devuelve socio ante valores desconocidos', () {
      expect(Rol.desde('admin').etiquetaAcceso, 'Administrador');
      expect(Rol.desde('coach').etiquetaAcceso, 'Instructor');
      expect(Rol.desde('socio').etiquetaAcceso, 'Cliente');
      expect(Rol.desde(null), Rol.socio);
      expect(Rol.desde('inventado'), Rol.socio);
    });

    test('Usuario.desdeMapa tolera campos ausentes o nulos', () {
      final u = Usuario.desdeMapa(const {'id': 'abc'});
      expect(u.id, 'abc');
      expect(u.nombre, '');
      expect(u.rol, Rol.socio);
      expect(u.activo, isTrue);
      expect(u.fechaRegistro, isNull);
      expect(u.nombreCompleto, '');
      expect(u.iniciales, '');
    });

    test('Usuario.desdeMapa lee una fila real de Supabase', () {
      final u = Usuario.desdeMapa(const {
        'id': 'abc',
        'nombre': 'Ana',
        'apellidos': 'Torres',
        'correo': 'ana@x.com',
        'telefono': '555',
        'rol': 'admin',
        'activo': false,
        'fecha_registro': '2026-01-15T10:00:00.000Z',
      });
      expect(u.nombreCompleto, 'Ana Torres');
      expect(u.rol, Rol.admin);
      expect(u.activo, isFalse);
      expect(u.fechaRegistro, isNotNull);
      expect(u.iniciales, 'AT');
    });

    test('Formato.dinero separa miles y muestra dos decimales', () {
      expect(Formato.dinero(0), r'$0.00');
      expect(Formato.dinero(1234.5), r'$1,234.50');
      expect(Formato.dinero(1234567.89), r'$1,234,567.89');
    });

    test('Formato.fecha devuelve guion cuando no hay fecha', () {
      expect(Formato.fecha(null), '—');
      expect(Formato.fecha(DateTime(2026, 3, 7)), '07/03/2026');
    });
  });

  group('Arranque y login', () {
    testWidgets('restaura la sesion y muestra el login sin backend',
        (WidgetTester tester) async {
      unawaited(Sesion.instancia.iniciar());
      await _abrirApp(tester, const Size(360, 740));

      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);
    });

    testWidgets('valida los campos vacios sin llamar al servidor',
        (WidgetTester tester) async {
      await _abrirApp(tester, const Size(360, 740));

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(find.text('Escribe tu correo'), findsOneWidget);
      expect(find.text('Escribe tu contraseña'), findsOneWidget);
      expect(Sesion.instancia.error, isNull);
    });

    testWidgets('valida el formato del correo',
        (WidgetTester tester) async {
      await _abrirApp(tester, const Size(360, 740));

      await tester.enterText(
        find.byType(TextFormField).first,
        'correo-sin-arroba',
      );
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(find.text('Correo no válido'), findsOneWidget);
    });

    testWidgets('permite cambiar el rol de acceso',
        (WidgetTester tester) async {
      await _abrirApp(tester, const Size(360, 740));

      await tester.tap(find.text('Cliente'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Cliente'), findsWidgets);
      expect(find.text('Administrador'), findsOneWidget);
    });

    testWidgets('abre la pantalla de registro',
        (WidgetTester tester) async {
      await _abrirApp(tester, const Size(360, 740));

      await tester.ensureVisible(find.text('Crear cuenta'));
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Tipo de cuenta'), findsOneWidget);
      expect(find.text('Registrarme'), findsOneWidget);
    });

  });

  group('Diseno adaptable', () {
    for (final tamano in const <Size>[
      Size(320, 568), // telefono pequeno
      Size(360, 740), // telefono tipico
      Size(412, 915), // telefono grande
      Size(600, 1024), // tableta vertical
      Size(900, 800), // tableta horizontal
      Size(1440, 900), // escritorio
    ]) {
      testWidgets('el login no desborda en ${tamano.width.toInt()}x'
          '${tamano.height.toInt()}', (WidgetTester tester) async {
        await _abrirApp(tester, tamano);
        expect(find.text('Iniciar sesión'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('en pantallas anchas muestra la columna de marca',
        (WidgetTester tester) async {
      await _abrirApp(tester, const Size(1440, 900));

      expect(find.text('Todo tu gimnasio,\nen un solo panel.'), findsOneWidget);
      expect(
        find.text(
          'Gestiona socios, instructores, clases, membresías, pagos y '
          'reportes en tiempo real, desde donde estés.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('en movil no muestra la columna de marca',
        (WidgetTester tester) async {
      await _abrirApp(tester, const Size(360, 740));

      expect(find.text('Todo tu gimnasio,\nen un solo panel.'), findsNothing);
    });
  });
}
