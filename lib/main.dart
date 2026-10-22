import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/rutas.dart';
import 'core/tema.dart';
import 'datos/auth_servicio.dart';
import 'estado/control_tema.dart';
import 'estado/sesion.dart';
import 'pantallas/admin/panel_admin.dart';
import 'pantallas/login.dart';
import 'pantallas/registro.dart';
import 'pantallas/sin_acceso.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase debe quedar listo antes de pintar la interfaz; si falla, la app
  // arranca igual y el login explica que no hay conexion con el servidor.
  try {
    await AuthServicio.instancia
        .inicializar()
        .timeout(const Duration(seconds: 12));
  } catch (_) {
    // Se informa en pantalla de login.
  }

  runApp(const AplicacionFitCore());

  // Limpia cualquier sesion guardada: el acceso se valida en cada arranque.
  unawaited(Sesion.instancia.iniciar());
}

class AplicacionFitCore extends StatelessWidget {
  const AplicacionFitCore({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Sesion>.value(
      value: Sesion.instancia,
      child: ChangeNotifierProvider<ControlTema>.value(
        value: ControlTema.instancia,
        child: Consumer<ControlTema>(
          builder: (context, controlTema, _) => MaterialApp(
            title: 'FitCore',
            debugShowCheckedModeBanner: false,
            theme: TemaFitCore.claro(),
            darkTheme: TemaFitCore.oscuro(),
            themeMode: controlTema.modo,
            routes: {
              Rutas.registro: (_) => const RegistroScreen(),
            },
            home: const PuertaAcceso(),
          ),
        ),
      ),
    );
  }
}

/// Decide que pantalla muestra segun el estado de la sesion.
class PuertaAcceso extends StatelessWidget {
  const PuertaAcceso({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<Sesion>();

    if (sesion.cargando) return const PantallaArranque();
    if (sesion.usuario == null) return const LoginScreen();
    if (sesion.esAdmin) return const PanelAdmin();
    return const SinAcceso();
  }
}

/// Pantalla de arranque mientras se restaura la sesion.
class PantallaArranque extends StatefulWidget {
  const PantallaArranque({super.key});

  @override
  State<PantallaArranque> createState() => _PantallaArranqueState();
}

class _PantallaArranqueState extends State<PantallaArranque>
    with SingleTickerProviderStateMixin {
  late final AnimationController _control;

  @override
  void initState() {
    super.initState();
    _control = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaFitCore.carbon,
      body: Center(
        child: AnimatedBuilder(
          animation: _control,
          builder: (context, _) {
            final t = _control.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [TemaFitCore.azul, TemaFitCore.cian],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: TemaFitCore.azul.withValues(alpha: 0.35 + 0.3 * t),
                        blurRadius: 24 + 16 * t,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'FitCore',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 26),
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: TemaFitCore.cian,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
