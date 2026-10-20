import 'package:flutter/material.dart';

import '../../core/error_fitcore.dart';
import '../../core/formato.dart';
import '../../datos/pagos_repo.dart';
import '../../datos/planes_repo.dart';
import '../../datos/usuarios_repo.dart';
import '../../modelos/membresia.dart';
import '../../modelos/plan.dart';
import '../../modelos/usuario.dart';
import '../../widgets/comunes.dart';

/// Gestión de membresías: planes y asignaciones a clientes.
class MembresiasAdmin extends StatefulWidget {
  const MembresiasAdmin({super.key});

  @override
  State<MembresiasAdmin> createState() => _MembresiasAdminState();
}

class _MembresiasAdminState extends State<MembresiasAdmin>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late Future<List<Membresia>> _futuroMembresias;
  late Future<List<PlanMembresia>> _futuroPlanes;
  List<Usuario> _socios = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _recargar();
    _cargarSocios();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _futuroMembresias = PagosRepo.instancia.listarMembresias();
      _futuroPlanes = PlanesRepo.instancia.listar();
    });
  }

  Future<void> _cargarSocios() async {
    try {
      _socios = await UsuariosRepo.instancia.listarPorRol(Rol.socio);
    } catch (_) {
      _socios = [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _abrirFormularioMembresia([Membresia? inicial]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoMembresia(
        inicial: inicial,
        socios: _socios,
      ),
    );
    if (guardado == true) _recargar();
  }

  Future<void> _abrirFormularioPlan([PlanMembresia? inicial]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoPlan(inicial: inicial),
    );
    if (guardado == true) _recargar();
  }

  Future<void> _confirmarEliminarMembresia(Membresia m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar membresía'),
        content: Text(
            '¿Seguro que quieres eliminar la membresía de ${m.socioNombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await PagosRepo.instancia.eliminarMembresia(m.id);
      _recargar();
      if (mounted) avisar(context, 'Membresía eliminada.');
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    }
  }

  Future<void> _confirmarEliminarPlan(PlanMembresia p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar plan'),
        content: Text('¿Seguro que quieres eliminar el plan "${p.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await PlanesRepo.instancia.eliminar(p.id);
      _recargar();
      if (mounted) avisar(context, 'Plan eliminado.');
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final es = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabs.index == 0) {
            _abrirFormularioMembresia();
          } else {
            _abrirFormularioPlan();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabs.index == 0 ? 'Asignar' : 'Nuevo plan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: es.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                  color: es.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: es.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Membresías'),
                  Tab(text: 'Planes'),
                ],
                onTap: (_) => setState(() {}),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _vistaMembresias(),
                _vistaPlanes(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vistaMembresias() {
    return FutureBuilder<List<Membresia>>(
      future: _futuroMembresias,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return EstadoVacio(
            icono: Icons.cloud_off,
            mensaje: snapshot.error.toString(),
          );
        }
        final lista = snapshot.data!;
        if (lista.isEmpty) {
          return const EstadoVacio(
            icono: Icons.card_membership_outlined,
            mensaje: 'No hay membresías registradas.',
          );
        }
        final activas = lista.where((m) => m.activa && !m.vencida).length;
        final vencidas = lista.where((m) => m.vencida).length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Row(
              children: [
                _resumen('Activas', '$activas', Colors.green),
                const SizedBox(width: 12),
                _resumen('Vencidas', '$vencidas', Colors.redAccent),
                const SizedBox(width: 12),
                _resumen('Total', '${lista.length}', Colors.blueGrey),
              ],
            ),
            const SizedBox(height: 16),
            for (final m in lista) ...[
              _tarjetaMembresia(m),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _resumen(String titulo, String valor, Color color) {
    final es = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              titulo,
              style: TextStyle(fontSize: 12.5, color: es.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaMembresia(Membresia m) {
    final es = Theme.of(context).colorScheme;
    final estado = m.vencida ? 'Vencida' : (m.activa ? 'Activa' : 'Inactiva');
    final colorEstado = m.vencida
        ? Colors.redAccent
        : (m.activa ? Colors.green : Colors.grey);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.socioNombre,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.plan,
                        style: TextStyle(
                          color: es.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    estado,
                    style: TextStyle(
                      color: colorEstado,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _dato(Icons.payments_outlined, Formato.dinero(m.precio)),
                _dato(Icons.calendar_today_outlined,
                    'Inicio: ${Formato.fecha(m.fechaInicio)}'),
                _dato(Icons.event_available_outlined,
                    'Fin: ${Formato.fecha(m.fechaFin)}'),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => _abrirFormularioMembresia(m),
                  child: const Text('Editar'),
                ),
                TextButton(
                  onPressed: () => _confirmarEliminarMembresia(m),
                  style: TextButton.styleFrom(foregroundColor: es.error),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(IconData icono, String texto) {
    final es = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 15, color: es.onSurfaceVariant),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: es.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _vistaPlanes() {
    return FutureBuilder<List<PlanMembresia>>(
      future: _futuroPlanes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return EstadoVacio(
            icono: Icons.cloud_off,
            mensaje: snapshot.error.toString(),
          );
        }
        final lista = snapshot.data!;
        if (lista.isEmpty) {
          return const EstadoVacio(
            icono: Icons.workspace_premium_outlined,
            mensaje: 'No hay planes de membresía.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          itemCount: lista.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _tarjetaPlan(lista[i]),
        );
      },
    );
  }

  Widget _tarjetaPlan(PlanMembresia p) {
    final es = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium_outlined, color: es.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.nombre,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  Formato.dinero(p.precio),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: es.primary,
                  ),
                ),
              ],
            ),
            if (p.descripcion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                p.descripcion,
                style: TextStyle(color: es.onSurfaceVariant, height: 1.4),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _chipSimple('${p.duracionDias} días', es),
                if (p.condiciones.isNotEmpty)
                  _chipSimple(p.condiciones, es),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => _abrirFormularioPlan(p),
                  child: const Text('Editar'),
                ),
                TextButton(
                  onPressed: () => _confirmarEliminarPlan(p),
                  style: TextButton.styleFrom(foregroundColor: es.error),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipSimple(String texto, ColorScheme es) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: es.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 12.5, color: es.onSurfaceVariant),
      ),
    );
  }
}

class _DialogoMembresia extends StatefulWidget {
  const _DialogoMembresia({
    required this.inicial,
    required this.socios,
  });

  final Membresia? inicial;
  final List<Usuario> socios;

  @override
  State<_DialogoMembresia> createState() => _DialogoMembresiaState();
}

class _DialogoMembresiaState extends State<_DialogoMembresia> {
  final _formulario = GlobalKey<FormState>();
  String? _socioId;
  String _plan = Membresia.planes.first;
  final _precio = TextEditingController();
  DateTime? _inicio;
  DateTime? _fin;
  bool _activa = true;
  bool _guardando = false;
  List<PlanMembresia> _planes = [];

  @override
  void initState() {
    super.initState();
    final ini = widget.inicial;
    if (ini != null) {
      _socioId = ini.socioId;
      _plan = ini.plan;
      _precio.text = ini.precio.toStringAsFixed(2);
      _inicio = ini.fechaInicio;
      _fin = ini.fechaFin;
      _activa = ini.activa;
    }
    _cargarPlanes();
  }

  Future<void> _cargarPlanes() async {
    try {
      _planes = await PlanesRepo.instancia.listar();
    } catch (_) {
      _planes = [];
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _precio.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha(bool inicio) async {
    final actual = inicio ? _inicio : _fin;
    final elegida = await showDatePicker(
      context: context,
      initialDate: actual ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (elegida == null) return;
    setState(() {
      if (inicio) {
        _inicio = elegida;
        if (_fin == null || _fin!.isBefore(elegida)) {
          _fin = elegida.add(const Duration(days: 30));
        }
      } else {
        _fin = elegida;
      }
    });
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    if (_socioId == null) {
      avisar(context, 'Selecciona un cliente.', error: true);
      return;
    }
    setState(() => _guardando = true);
    try {
      final socio =
          widget.socios.firstWhere((s) => s.id == _socioId, orElse: () => widget.socios.first);
      final ini = widget.inicial;
      final membresia = Membresia(
        id: ini?.id ?? '',
        socioId: _socioId!,
        socioNombre: socio.nombreCompleto,
        plan: _plan,
        precio: double.tryParse(_precio.text.trim()) ?? 0,
        fechaInicio: _inicio,
        fechaFin: _fin,
        activa: _activa,
      );
      await PagosRepo.instancia.guardarMembresia(membresia);
      if (mounted) Navigator.pop(context, true);
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final es = widget.inicial != null;
    final socios = widget.socios.where((s) => s.activo).toList();
    return AlertDialog(
      title: Text(es ? 'Editar membresía' : 'Asignar membresía'),
      content: SingleChildScrollView(
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!es) ...[
                DropdownButtonFormField<String?>(
                  initialValue: _socioId,
                  decoration: const InputDecoration(labelText: 'Cliente'),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('Selecciona...')),
                    for (final s in socios)
                      DropdownMenuItem<String?>(
                          value: s.id, child: Text(s.nombreCompleto)),
                  ],
                  onChanged: (v) => setState(() => _socioId = v),
                ),
                const SizedBox(height: 12),
              ] else
                TextFormField(
                  initialValue: widget.inicial!.socioNombre,
                  decoration: const InputDecoration(labelText: 'Cliente'),
                  enabled: false,
                ),
              if (_planes.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _plan,
                  decoration: const InputDecoration(labelText: 'Plan'),
                  items: [
                    for (final p in _planes)
                      DropdownMenuItem(value: p.nombre, child: Text(p.nombre)),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    final p = _planes.firstWhere((x) => x.nombre == v);
                    setState(() {
                      _plan = v;
                      _precio.text = p.precio.toStringAsFixed(2);
                      _inicio = DateTime.now();
                      _fin = DateTime.now().add(Duration(days: p.duracionDias));
                    });
                  },
                ),
                const SizedBox(height: 12),
              ] else ...[
                DropdownButtonFormField<String>(
                  initialValue: _plan,
                  decoration: const InputDecoration(labelText: 'Plan'),
                  items: [
                    for (final p in Membresia.planes)
                      DropdownMenuItem(value: p, child: Text(p)),
                  ],
                  onChanged: (v) => setState(() => _plan = v ?? _plan),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _precio,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Precio'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _botonFecha('Inicio', _inicio, () => _elegirFecha(true)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _botonFecha('Fin', _fin, () => _elegirFecha(false)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Membresía activa'),
                value: _activa,
                onChanged: (v) => setState(() => _activa = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _botonFecha(String etiqueta, DateTime? valor, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calendar_today_outlined, size: 16),
      label: Text(valor == null ? etiqueta : Formato.fecha(valor)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }
}

class _DialogoPlan extends StatefulWidget {
  const _DialogoPlan({this.inicial});

  final PlanMembresia? inicial;

  @override
  State<_DialogoPlan> createState() => _DialogoPlanState();
}

class _DialogoPlanState extends State<_DialogoPlan> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  final _duracion = TextEditingController();
  final _precio = TextEditingController();
  final _condiciones = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final ini = widget.inicial;
    if (ini != null) {
      _nombre.text = ini.nombre;
      _descripcion.text = ini.descripcion;
      _duracion.text = ini.duracionDias.toString();
      _precio.text = ini.precio.toStringAsFixed(2);
      _condiciones.text = ini.condiciones;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _duracion.dispose();
    _precio.dispose();
    _condiciones.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final ini = widget.inicial;
      final plan = PlanMembresia(
        id: ini?.id ?? '',
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        duracionDias: int.tryParse(_duracion.text.trim()) ?? 30,
        precio: double.tryParse(_precio.text.trim()) ?? 0,
        condiciones: _condiciones.text.trim(),
        activo: ini?.activo ?? true,
      );
      await PlanesRepo.instancia.guardar(plan);
      if (mounted) Navigator.pop(context, true);
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.inicial == null ? 'Nuevo plan' : 'Editar plan'),
      content: SingleChildScrollView(
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campo(_nombre, 'Nombre del plan'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _campo(_duracion, 'Duración (días)',
                        tipo: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _campo(_precio, 'Precio',
                        tipo: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _condiciones,
                decoration:
                    const InputDecoration(labelText: 'Condiciones'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _campo(TextEditingController controlador, String etiqueta,
      {TextInputType? tipo}) {
    return TextFormField(
      controller: controlador,
      keyboardType: tipo,
      decoration: InputDecoration(labelText: etiqueta),
      validator: (v) =>
          (v ?? '').trim().isEmpty ? 'Campo obligatorio' : null,
    );
  }
}
