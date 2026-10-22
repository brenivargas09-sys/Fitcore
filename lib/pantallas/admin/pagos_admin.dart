import 'package:flutter/material.dart';

import '../../core/error_fitcore.dart';
import '../../core/formato.dart';
import '../../datos/pagos_repo.dart';
import '../../datos/usuarios_repo.dart';
import '../../modelos/pago.dart';
import '../../modelos/usuario.dart';
import '../../widgets/comunes.dart';

/// Registro y consulta de pagos de los clientes.
class PagosAdmin extends StatefulWidget {
  const PagosAdmin({super.key});

  @override
  State<PagosAdmin> createState() => _PagosAdminState();
}

class _PagosAdminState extends State<PagosAdmin> {
  late Future<_Datos> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<_Datos> _cargar() async {
    final socios = await UsuariosRepo.instancia.listarPorRol(Rol.socio);
    final pagos = await PagosRepo.instancia.listarPagos();
    return _Datos(socios: socios, pagos: pagos);
  }

  void _recargar() {
    setState(() {
      _futuro = _cargar();
    });
  }

  Future<void> _nuevo() async {
    final socios = (await _futuro).socios;
    if (!mounted) return;
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoPago(socios: socios),
    );
    if (guardado == true) _recargar();
  }

  Future<void> _confirmarEliminar(Pago pago) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar pago'),
        content: Text(
            '¿Seguro que quieres eliminar el pago de "${pago.concepto}"?'),
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
    if (confirmado != true) return;
    try {
      await PagosRepo.instancia.eliminarPago(pago.id);
      _recargar();
      if (mounted) avisar(context, 'Pago eliminado.');
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevo,
        icon: const Icon(Icons.add),
        label: const Text('Registrar pago'),
      ),
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
          final pagos = snapshot.data!.pagos;
          if (pagos.isEmpty) {
            return const EstadoVacio(
              icono: Icons.receipt_long_outlined,
              mensaje: 'No hay pagos registrados.',
            );
          }
          final total = pagos
              .where((p) => p.pagado)
              .fold<double>(0, (s, p) => s + p.monto);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            children: [
              _resumen(pagos.length, total),
              const SizedBox(height: 16),
              for (final p in pagos) ...[
                _tarjeta(p),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _resumen(int cantidad, double total) {
    final es = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            es.primary.withValues(alpha: 0.16),
            es.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: es.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: es.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formato.dinero(total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: es.primary,
                  ),
                ),
                Text(
                  'Total cobrado · $cantidad pagos',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: es.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(Pago p) {
    final es = Theme.of(context).colorScheme;
    final ok = p.pagado;
    final color = ok ? const Color(0xFF2E9E5B) : es.error;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(
                ok ? Icons.attach_money : Icons.schedule,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.socioNombre.isEmpty ? p.socioId : p.socioNombre,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${p.concepto} · ${p.metodo}',
                    style: TextStyle(
                      color: es.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    Formato.fechaHora(p.fecha),
                    style: TextStyle(
                      color: es.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formato.dinero(p.monto),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  ok ? 'Pagado' : 'Pendiente',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (valor) {
                if (valor == 'editar') {
                  _editar(p);
                } else if (valor == 'eliminar') {
                  _confirmarEliminar(p);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                  ),
                ),
                PopupMenuItem(
                  value: 'eliminar',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline),
                    title: Text('Eliminar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editar(Pago pago) async {
    final socios = (await _futuro).socios;
    if (!mounted) return;
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoPago(socios: socios, inicial: pago),
    );
    if (guardado == true) _recargar();
  }
}

class _Datos {
  const _Datos({required this.socios, required this.pagos});

  final List<Usuario> socios;
  final List<Pago> pagos;
}

String _nombreDe(List<Usuario> socios, String? id) {
  for (final u in socios) {
    if (u.id == id) return u.nombreCompleto;
  }
  return '';
}

class _DialogoPago extends StatefulWidget {
  const _DialogoPago({required this.socios, this.inicial});

  final List<Usuario> socios;
  final Pago? inicial;

  @override
  State<_DialogoPago> createState() => _DialogoPagoState();
}

class _DialogoPagoState extends State<_DialogoPago> {
  String? _socioId;
  late final TextEditingController _concepto;
  late final TextEditingController _monto;
  String _metodo = Pago.metodos.first;
  DateTime _fecha = DateTime.now();
  bool _pagado = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final p = widget.inicial;
    _socioId = p?.socioId;
    _concepto = TextEditingController(text: p?.concepto ?? 'Mensualidad');
    _monto = TextEditingController(text: (p?.monto ?? 39.9).toStringAsFixed(2));
    _metodo = p?.metodo ?? Pago.metodos.first;
    _fecha = p?.fecha ?? DateTime.now();
    _pagado = p?.pagado ?? true;
  }

  @override
  void dispose() {
    _concepto.dispose();
    _monto.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegido = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (elegido != null) setState(() => _fecha = elegido);
  }

  Future<void> _guardar() async {
    if (_socioId == null) {
      avisar(context, 'Selecciona un cliente.', error: true);
      return;
    }
    setState(() => _guardando = true);
    final pago = Pago(
      id: widget.inicial?.id ?? '',
      socioId: _socioId!,
      socioNombre: _nombreDe(widget.socios, _socioId),
      concepto: _concepto.text.trim(),
      monto: double.tryParse(_monto.text.replaceAll(',', '.')) ?? 0,
      metodo: _metodo,
      fecha: _fecha,
      pagado: _pagado,
    );
    try {
      await PagosRepo.instancia.registrarPago(pago);
      if (mounted) Navigator.pop(context, true);
    } on ErrorFitCore catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        avisar(context, e.mensaje, error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final edicion = widget.inicial != null;
    return AlertDialog(
      title: Text(edicion ? 'Editar pago' : 'Registrar pago'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _socioId,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: [
                  for (final s in widget.socios)
                    DropdownMenuItem(value: s.id, child: Text(s.nombreCompleto)),
                ],
                onChanged: (v) => setState(() => _socioId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _concepto,
                decoration: const InputDecoration(labelText: 'Concepto'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _monto,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Monto'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _metodo,
                      decoration: const InputDecoration(labelText: 'Método'),
                      items: [
                        for (final m in Pago.metodos)
                          DropdownMenuItem(value: m, child: Text(m)),
                      ],
                      onChanged: (v) => setState(() => _metodo = v ?? _metodo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Fecha'),
                subtitle: Text(Formato.fecha(_fecha)),
                trailing: TextButton(
                  onPressed: _elegirFecha,
                  child: const Text('Cambiar'),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Marcar como pagado'),
                value: _pagado,
                onChanged: (v) => setState(() => _pagado = v),
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
}
