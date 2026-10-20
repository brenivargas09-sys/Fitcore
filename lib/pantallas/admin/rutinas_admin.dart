import 'package:flutter/material.dart';

import '../../core/error_fitcore.dart';
import '../../datos/clases_repo.dart';
import '../../datos/usuarios_repo.dart';
import '../../modelos/rutina.dart';
import '../../modelos/usuario.dart';
import '../../widgets/comunes.dart';

class RutinasAdmin extends StatefulWidget {
  const RutinasAdmin({super.key});

  @override
  State<RutinasAdmin> createState() => _RutinasAdminState();
}

class _RutinasAdminState extends State<RutinasAdmin> {
  late Future<List<Rutina>> _futuro;
  List<Usuario> _coaches = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _futuro = ClasesRepo.instancia.listarRutinas();
    });
    try {
      _coaches = await UsuariosRepo.instancia.listar();
    } catch (_) {
      _coaches = [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _abrirFormulario([Rutina? inicial]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoRutina(inicial: inicial, coaches: _coaches),
    );
    if (guardado == true) _cargar();
  }

  Future<void> _confirmarEliminar(Rutina rutina) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar rutina'),
        content: Text('¿Seguro que quieres eliminar "${rutina.nombre}"?'),
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
      await ClasesRepo.instancia.eliminarRutina(rutina.id);
      _cargar();
      if (mounted) avisar(context, 'Rutina eliminada.');
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.fitness_center),
        label: const Text('Nueva rutina'),
      ),
      body: FutureBuilder<List<Rutina>>(
        future: _futuro,
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
              icono: Icons.fitness_center_outlined,
              mensaje: 'No hay rutinas registradas.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            itemCount: lista.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _tarjeta(lista[i]),
          );
        },
      ),
    );
  }

  Widget _tarjeta(Rutina r) {
    final es = Theme.of(context).colorScheme;
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
                        r.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.coachNombre.isEmpty
                            ? 'Sin entrenador asignado'
                            : r.coachNombre,
                        style: TextStyle(
                          color: es.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(r.activa ? 'Activa' : 'Inactiva'),
                  backgroundColor: r.activa
                      ? es.primary.withValues(alpha: 0.16)
                      : es.surfaceContainerHighest,
                ),
              ],
            ),
            if (r.descripcion.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                r.descripcion,
                style: TextStyle(
                  height: 1.4,
                  color: es.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: es.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    r.nivel,
                    style: TextStyle(
                      color: es.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text('${r.semanas} semanas'),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => _abrirFormulario(r),
                  child: const Text('Editar'),
                ),
                TextButton(
                  onPressed: () => _confirmarEliminar(r),
                  style: TextButton.styleFrom(
                    foregroundColor: es.error,
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogoRutina extends StatefulWidget {
  const _DialogoRutina({
    required this.inicial,
    required this.coaches,
  });

  final Rutina? inicial;
  final List<Usuario> coaches;

  @override
  State<_DialogoRutina> createState() => _DialogoRutinaState();
}

class _DialogoRutinaState extends State<_DialogoRutina> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  final _semanas = TextEditingController();
  String _nivel = Rutina.niveles.first;
  String? _coachId;
  String _coachNombre = '';
  bool _activa = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final ini = widget.inicial;
    if (ini != null) {
      _nombre.text = ini.nombre;
      _descripcion.text = ini.descripcion;
      _semanas.text = ini.semanas.toString();
      _nivel = ini.nivel;
      _coachId = ini.coachId;
      _coachNombre = ini.coachNombre;
      _activa = ini.activa;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _semanas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final ini = widget.inicial;
      final semanas = int.tryParse(_semanas.text.trim()) ?? 4;
      final rutina = (ini ??
              Rutina(
                id: '',
                nombre: '',
                coachId: _coachId,
                coachNombre: _coachNombre,
              )).copyWith(
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        coachId: _coachId,
        coachNombre: _coachNombre,
        nivel: _nivel,
        semanas: semanas,
        activa: _activa,
      );
      await ClasesRepo.instancia.guardarRutina(rutina);
      if (mounted) Navigator.pop(context, true);
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coaches = widget.coaches
        .where((u) => u.rol == Rol.coach && u.activo)
        .toList();
    return AlertDialog(
      title: Text(widget.inicial == null ? 'Nueva rutina' : 'Editar rutina'),
      content: SingleChildScrollView(
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campo(_nombre, 'Nombre de la rutina'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _nivel,
                decoration: const InputDecoration(labelText: 'Nivel'),
                items: [
                  for (final n in Rutina.niveles)
                    DropdownMenuItem(value: n, child: Text(n)),
                ],
                onChanged: (v) =>
                    setState(() => _nivel = v ?? Rutina.niveles.first),
              ),
              const SizedBox(height: 12),
              _campo(_semanas, 'Semanas de duración',
                  tipo: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _coachId,
                decoration:
                    const InputDecoration(labelText: 'Entrenador asignado'),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('Sin asignar')),
                  for (final c in coaches)
                    DropdownMenuItem<String?>(
                        value: c.id, child: Text(c.nombreCompleto)),
                ],
                onChanged: (v) {
                  setState(() {
                    _coachId = v;
                    if (v == null) {
                      _coachNombre = '';
                    } else {
                      final c = coaches.firstWhere((x) => x.id == v);
                      _coachNombre = c.nombreCompleto;
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Rutina activa'),
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

  Widget _campo(TextEditingController controlador, String etiqueta,
      {TextInputType? tipo}) {
    return TextFormField(
      controller: controlador,
      keyboardType: tipo,
      decoration: InputDecoration(labelText: etiqueta),
      validator: (v) {
        final t = (v ?? '').trim();
        if (t.isEmpty) return 'Campo obligatorio';
        return null;
      },
    );
  }
}
