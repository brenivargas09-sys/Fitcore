import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fitcore/core/config_supabase.dart';
import 'package:fitcore/core/tema.dart';
import 'package:fitcore/datos/auth_servicio.dart';
import 'package:fitcore/estado/sesion.dart';
import 'package:fitcore/pantallas/admin/avisos_admin.dart';
import 'package:fitcore/pantallas/admin/clases_admin.dart';
import 'package:fitcore/pantallas/admin/configuracion_admin.dart';
import 'package:fitcore/pantallas/admin/info_gimnasio_admin.dart';
import 'package:fitcore/pantallas/admin/inicio_admin.dart';
import 'package:fitcore/pantallas/admin/instructores_admin.dart';
import 'package:fitcore/pantallas/admin/membresias_admin.dart';
import 'package:fitcore/pantallas/admin/pagos_admin.dart';
import 'package:fitcore/pantallas/admin/reportes_admin.dart';
import 'package:fitcore/pantallas/admin/rutinas_admin.dart';
import 'package:fitcore/pantallas/admin/usuarios_admin.dart';

/// Comprueba que las 11 pantallas del panel se construyen sin desbordes en
/// tamanos de movil, tableta y escritorio.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    ConfigSupabase.forzarDemo = true;
    await AuthServicio.instancia.inicializar();
    final ok = await Sesion.instancia.entrar('admin@fitcore.com', 'admin123');
    expect(ok, isTrue, reason: 'El modo demo debe permitir entrar como admin');
  });

  tearDownAll(() async {
    await Sesion.instancia.salir();
    ConfigSupabase.forzarDemo = false;
  });

  final pantallas = <String, Widget Function()>{
    'Inicio': () => const InicioAdmin(),
    'Clientes': () => const UsuariosAdmin(),
    'Instructores': () => const InstructoresAdmin(),
    'Clases': () => const ClasesAdmin(),
    'Rutinas': () => const RutinasAdmin(),
    'Membresias': () => const MembresiasAdmin(),
    'Pagos': () => const PagosAdmin(),
    'Avisos': () => const AvisosAdmin(),
    'Informacion': () => const InfoGimnasioAdmin(),
    'Reportes': () => const ReportesAdmin(),
    'Configuracion': () => const ConfiguracionAdmin(),
  };

  const tamanos = <Size>[
    Size(320, 568),
    Size(360, 740),
    Size(412, 915),
    Size(600, 1024),
    Size(1024, 768),
    Size(1440, 900),
  ];

  for (final tamano in tamanos) {
    group(
      'Panel ${tamano.width.toInt()}x${tamano.height.toInt()}',
      () {
        for (final entrada in pantallas.entries) {
          testWidgets(entrada.key, (WidgetTester tester) async {
            tester.view.devicePixelRatio = 2.0;
            tester.view.physicalSize = tamano * 2.0;
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(tester.view.resetPhysicalSize);

            await tester.pumpWidget(_conSesion(entrada.value()));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 400));

            expect(tester.takeException(), isNull);

            // El mismo contenido dentro de un scroll no debe desbordar.
            final scrollable = find.byType(Scrollable);
            if (scrollable.evaluate().isNotEmpty) {
              await tester.drag(scrollable.first, const Offset(0, -240));
              await tester.pump(const Duration(milliseconds: 200));
              expect(tester.takeException(), isNull);
            }
          });
        }
      },
    );
  }
}

Widget _conSesion(Widget pantalla) {
  return ChangeNotifierProvider<Sesion>.value(
    value: Sesion.instancia,
    child: MaterialApp(
      theme: TemaFitCore.claro(),
      home: Scaffold(body: pantalla),
    ),
  );
}
