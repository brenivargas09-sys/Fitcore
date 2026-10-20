import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../datos/clases_repo.dart';
import '../../datos/pagos_repo.dart';
import '../../datos/usuarios_repo.dart';
import '../../modelos/clase.dart';
import '../../modelos/pago.dart';
import '../../modelos/usuario.dart';
import '../../widgets/comunes.dart';

/// Resumen general del gimnasio: indicadores, clases de hoy y últimos pagos.
class InicioAdmin extends StatefulWidget {
  const InicioAdmin({super.key});

  @override
  State<InicioAdmin> createState() => _InicioAdminState();
}

class _InicioAdminState extends State<InicioAdmin> {
  late Future<_Resumen> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<_Resumen> _cargar() async {
    final usuarios = await UsuariosRepo.instancia.listar();
    final clases = await ClasesRepo.instancia.listarClases();
    final pagos = await PagosRepo.instancia.listarPagos();
    final membresias = await PagosRepo.instancia.listarMembresias();

    final hoy = DateTime.now();
    final socios = usuarios.where((u) => u.rol == Rol.socio).length;
    final coaches = usuarios.where((u) => u.rol == Rol.coach).length;
    final clasesHoy =
        clases.where((c) => c.activa && c.diaSemana == hoy.weekday).toList();
    final ingresosMes = pagos
        .where((p) =>
            p.pagado &&
            p.fecha != null &&
            p.fecha!.year == hoy.year &&
            p.fecha!.month == hoy.month)
        .fold<double>(0, (s, p) => s + p.monto);
    final activas = membresias.where((m) => m.activa && !m.vencida).length;

    return _Resumen(
      socios: socios,
      coaches: coaches,
      clasesHoy: clasesHoy,
      ingresosMes: ingresosMes,
      membresiasActivas: activas,
      ultimosPagos: pagos.take(6).toList(),
    );
  }

  Future<void> _recargar() async {
    setState(() {
      _futuro = _cargar();
    });
    await _futuro;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Resumen>(
      future: _futuro,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return EstadoVacio(
            icono: Icons.cloud_off,
            mensaje: '${snapshot.error}',
          );
        }
        final datos = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _recargar,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _saludo(context),
              const SizedBox(height: 20),
              _indicadores(context, datos),
              const SizedBox(height: 24),
              _clasesDeHoy(context, datos.clasesHoy),
              const SizedBox(height: 24),
              _actividad(context, datos.ultimosPagos),
            ],
          ),
        );
      },
    );
  }

  Widget _saludo(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¡Bienvenido a FitCore!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Este es el estado actual del gimnasio.',
          style: TextStyle(color: esquema.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _indicadores(BuildContext context, _Resumen d) {
    final tarjetas = [
      TarjetaEstadistica(
        titulo: 'Socios',
        valor: '${d.socios}',
        icono: Icons.people_alt_outlined,
        color: const Color(0xFF2E7BFF),
      ),
      TarjetaEstadistica(
        titulo: 'Entrenadores',
        valor: '${d.coaches}',
        icono: Icons.sports_gymnastics,
        color: const Color(0xFF22D3EE),
      ),
      TarjetaEstadistica(
        titulo: 'Membresías activas',
        valor: '${d.membresiasActivas}',
        icono: Icons.card_membership,
        color: const Color(0xFF7C5CFF),
      ),
      TarjetaEstadistica(
        titulo: 'Ingresos del mes',
        valor: Formato.dinero(d.ingresosMes),
        icono: Icons.trending_up,
        color: const Color(0xFF2E9E5B),
      ),
    ];

    return LayoutBuilder(
      builder: (context, restricciones) {
        final columnas = restricciones.maxWidth >= 1000
            ? 4
            : restricciones.maxWidth >= 640
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: columnas,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          // Altura fija: evita desbordes en movil (1 columna) y en textos
          // con escala ampliada.
          mainAxisExtent: 184,
          children: tarjetas,
        );
      },
    );
  }

  Widget _clasesDeHoy(BuildContext context, List<Clase> clases) {
    return _panel(
      context,
      titulo: 'Clases de hoy',
      hijo: clases.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No hay clases programadas para hoy.'),
            )
          : Column(
              children: [
                for (final c in clases)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        c.hora,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    title: Text(c.nombre),
                    subtitle: Text('${c.sala} · ${c.coachNombre}'),
                    trailing: Text('${c.duracionMin} min'),
                  ),
              ],
            ),
    );
  }

  Widget _actividad(BuildContext context, List<Pago> pagos) {
    return _panel(
      context,
      titulo: 'Últimos pagos',
      hijo: pagos.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Todavía no hay pagos registrados.'),
            )
          : Column(
              children: [
                for (final p in pagos)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2E9E5B).withValues(alpha: 0.15),
                      child: const Icon(Icons.attach_money, color: Color(0xFF2E9E5B)),
                    ),
                    title: Text(p.socioNombre.isEmpty ? p.concepto : p.socioNombre),
                    subtitle: Text('${p.concepto} · ${p.metodo}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formato.dinero(p.monto),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          Formato.fecha(p.fecha),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _panel(
    BuildContext context, {
    required String titulo,
    required Widget hijo,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          hijo,
        ],
      ),
    );
  }
}

class _Resumen {
  const _Resumen({
    required this.socios,
    required this.coaches,
    required this.clasesHoy,
    required this.ingresosMes,
    required this.membresiasActivas,
    required this.ultimosPagos,
  });

  final int socios;
  final int coaches;
  final List<Clase> clasesHoy;
  final double ingresosMes;
  final int membresiasActivas;
  final List<Pago> ultimosPagos;
}
