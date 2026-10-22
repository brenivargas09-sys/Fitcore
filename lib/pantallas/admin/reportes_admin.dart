import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../datos/clases_repo.dart';
import '../../datos/pagos_repo.dart';
import '../../datos/usuarios_repo.dart';
import '../../modelos/clase.dart';
import '../../modelos/membresia.dart';
import '../../modelos/pago.dart';
import '../../modelos/rutina.dart';
import '../../modelos/usuario.dart';
import '../../widgets/comunes.dart';

/// Consulta de reportes generados a partir de la información almacenada.
class ReportesAdmin extends StatefulWidget {
  const ReportesAdmin({super.key});

  @override
  State<ReportesAdmin> createState() => _ReportesAdminState();
}

enum _Periodo { mes, anio, todo }

class _ReportesAdminState extends State<ReportesAdmin> {
  late Future<_Datos> _futuro;
  _Periodo _periodo = _Periodo.todo;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<_Datos> _cargar() async {
    final usuarios = await UsuariosRepo.instancia.listar();
    final clases = await ClasesRepo.instancia.listarClases();
    final rutinas = await ClasesRepo.instancia.listarRutinas();
    final membresias = await PagosRepo.instancia.listarMembresias();
    final pagos = await PagosRepo.instancia.listarPagos();
    return _Datos(
      usuarios: usuarios,
      clases: clases,
      rutinas: rutinas,
      membresias: membresias,
      pagos: pagos,
    );
  }

  void _recargar() {
    setState(() {
      _futuro = _cargar();
    });
  }

  bool _enPeriodo(DateTime? fecha) {
    if (fecha == null) return false;
    final ahora = DateTime.now();
    switch (_periodo) {
      case _Periodo.mes:
        return fecha.year == ahora.year && fecha.month == ahora.month;
      case _Periodo.anio:
        return fecha.year == ahora.year;
      case _Periodo.todo:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_Datos>(
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
          final d = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reportes del gimnasio',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: _recargar,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _selectorPeriodo(),
              const SizedBox(height: 20),
              _indicadores(d),
              const SizedBox(height: 24),
              _porPlan(d.membresias),
              const SizedBox(height: 16),
              _porMetodo(d.pagos),
              const SizedBox(height: 16),
              _porDia(d.clases),
            ],
          );
        },
      ),
    );
  }

  Widget _selectorPeriodo() {
    // Scroll horizontal: el selector no desborda en pantallas estrechas.
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<_Periodo>(
          segments: const [
            ButtonSegment(value: _Periodo.mes, label: Text('Este mes')),
            ButtonSegment(value: _Periodo.anio, label: Text('Este año')),
            ButtonSegment(value: _Periodo.todo, label: Text('Todo')),
          ],
          selected: {_periodo},
          onSelectionChanged: (s) => setState(() => _periodo = s.first),
        ),
      ),
    );
  }

  Widget _indicadores(_Datos d) {
    final socios = d.usuarios.where((u) => u.rol == Rol.socio).length;
    final coaches = d.usuarios.where((u) => u.rol == Rol.coach).length;
    final activas = d.membresias.where((m) => m.activa && !m.vencida).length;
    final vencidas = d.membresias.where((m) => m.vencida).length;
    final pagosPeriodo = d.pagos.where((p) => _enPeriodo(p.fecha)).toList();
    final recaudado =
        pagosPeriodo.where((p) => p.pagado).fold<double>(0, (s, p) => s + p.monto);

    final tarjetas = [
      TarjetaEstadistica(
        titulo: 'Clientes registrados',
        valor: '$socios',
        icono: Icons.people_alt_outlined,
        color: const Color(0xFF2E7BFF),
      ),
      TarjetaEstadistica(
        titulo: 'Instructores activos',
        valor: '${d.usuarios.where((u) => u.rol == Rol.coach && u.activo).length}/$coaches',
        icono: Icons.sports_gymnastics,
        color: const Color(0xFF22D3EE),
      ),
      TarjetaEstadistica(
        titulo: 'Membresías activas',
        valor: '$activas',
        icono: Icons.card_membership,
        color: const Color(0xFF2E9E5B),
      ),
      TarjetaEstadistica(
        titulo: 'Membresías vencidas',
        valor: '$vencidas',
        icono: Icons.event_busy_outlined,
        color: const Color(0xFFE05252),
      ),
      TarjetaEstadistica(
        titulo: 'Pagos registrados',
        valor: '${pagosPeriodo.length}',
        icono: Icons.receipt_long_outlined,
        color: const Color(0xFF7C5CFF),
      ),
      TarjetaEstadistica(
        titulo: 'Recaudado',
        valor: Formato.dinero(recaudado),
        icono: Icons.trending_up,
        color: const Color(0xFF2E9E5B),
      ),
      TarjetaEstadistica(
        titulo: 'Rutinas disponibles',
        valor: '${d.rutinas.where((r) => r.activa).length}',
        icono: Icons.fitness_center,
        color: const Color(0xFF22D3EE),
      ),
      TarjetaEstadistica(
        titulo: 'Clases programadas',
        valor: '${d.clases.where((c) => c.activa).length}',
        icono: Icons.event_note_outlined,
        color: const Color(0xFF2E7BFF),
      ),
    ];

    return LayoutBuilder(
      builder: (context, restricciones) {
        final columnas = restricciones.maxWidth >= 1100
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
          // Altura fija: evita desbordes en movil (1 columna).
          mainAxisExtent: 184,
          children: tarjetas,
        );
      },
    );
  }

  Widget _porPlan(List<Membresia> membresias) {
    final conteo = <String, int>{};
    for (final m in membresias) {
      conteo[m.plan] = (conteo[m.plan] ?? 0) + 1;
    }
    return _panel(
      'Membresías por plan',
      conteo.isEmpty
          ? 'Sin membresías registradas.'
          : null,
      conteo,
      const Color(0xFF7C5CFF),
    );
  }

  Widget _porMetodo(List<Pago> pagos) {
    final filtrados = pagos.where((p) => _enPeriodo(p.fecha)).toList();
    final conteo = <String, int>{};
    for (final p in filtrados) {
      conteo[p.metodo] = (conteo[p.metodo] ?? 0) + 1;
    }
    return _panel(
      'Pagos por método',
      conteo.isEmpty ? 'Sin pagos en el periodo.' : null,
      conteo,
      const Color(0xFF2E9E5B),
    );
  }

  Widget _porDia(List<Clase> clases) {
    final conteo = <String, int>{};
    for (final c in clases.where((c) => c.activa)) {
      conteo[c.diaEtiqueta] = (conteo[c.diaEtiqueta] ?? 0) + 1;
    }
    return _panel(
      'Clases por día',
      conteo.isEmpty ? 'Sin clases programadas.' : null,
      conteo,
      const Color(0xFF2E7BFF),
    );
  }

  Widget _panel(
    String titulo,
    String? vacio,
    Map<String, int> datos,
    Color color,
  ) {
    final es = Theme.of(context).colorScheme;
    final total = datos.values.fold<int>(0, (s, v) => s + v);
    final maximo = datos.values.isEmpty
        ? 1
        : datos.values.reduce((a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            if (vacio != null)
              Text(
                vacio,
                style: TextStyle(color: es.onSurfaceVariant),
              )
            else
              for (final entrada in datos.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entrada.key,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${entrada.value} '
                            '(${total == 0 ? 0 : (entrada.value * 100 / total).round()}%)',
                            style: TextStyle(color: es.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: maximo == 0 ? 0 : entrada.value / maximo,
                          minHeight: 8,
                          backgroundColor: es.surfaceContainerHighest,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _Datos {
  const _Datos({
    required this.usuarios,
    required this.clases,
    required this.rutinas,
    required this.membresias,
    required this.pagos,
  });

  final List<Usuario> usuarios;
  final List<Clase> clases;
  final List<Rutina> rutinas;
  final List<Membresia> membresias;
  final List<Pago> pagos;
}
