import 'package:flutter/material.dart';

import '../../core/error_fitcore.dart';
import '../../datos/clases_repo.dart';
import '../../datos/usuarios_repo.dart';
import '../../modelos/clase.dart';
import '../../modelos/usuario.dart';
import '../../widgets/comunes.dart';

/// Programación de clases dirigidas y sus horarios.
class ClasesAdmin extends StatefulWidget {
  const ClasesAdmin({super.key});

  @override
  State<ClasesAdmin> createState() => _ClasesAdminState();
}

class _ClasesAdminState extends State<ClasesAdmin> {
  late Future<List<Clase>> _futuro;
  List<Usuario> _coaches = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _futuro = ClasesRepo.instancia.listarClases();
    });
    try {
      _coaches = await UsuariosRepo.instancia.listarPorRol(Rol.coach);
    } catch (_) {
      _coaches = const [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _nuevo([Clase? inicial]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoClase(inicial: inicial, coaches: _coaches),
    );
    if (guardado == true) _cargar();
  }

  Future<void> _confirmarEliminar(Clase clase) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar clase'),
        content: Text('¿Seguro que quieres eliminar "${clase.nombre}"?'),
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
      await ClasesRepo.instancia.eliminarClase(clase.id);
      _cargar();
      if (mounted) avisar(context, 'Clase eliminada.');
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _nuevo(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva clase'),
      ),
      body: FutureBuilder<List<Clase>>(
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
          final clases = snapshot.data!;
          if (clases.isEmpty) {
            return const EstadoVacio(
              icono: Icons.event_busy_outlined,
              mensaje: 'No hay clases creadas todavía.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            itemCount: clases.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _tarjeta(clases[i]),
          );
        },
      ),
    );
  }

  Widget _tarjeta(Clase c) {
    final esquema = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: esquema.primary.withValues(alpha: 0.15),
                  child: Icon(Icons.fitness_center, color: esquema.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.nombre,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.coachNombre.isEmpty
                            ? 'Sin entrenador asignado'
                            : c.coachNombre,
                        style: TextStyle(
                          color: esquema.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!c.activa)
                  const Chip(label: Text('Inactiva')),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _dato(Icons.schedule, c.horario, esquema),
                _dato(Icons.meeting_room_outlined, c.sala, esquema),
                _dato(Icons.groups_outlined, '${c.cupoMax} plazas', esquema),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => _nuevo(c),
                  child: const Text('Editar'),
                ),
                TextButton(
                  onPressed: () => _confirmarEliminar(c),
                  style: TextButton.styleFrom(foregroundColor: esquema.error),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(IconData icono, String texto, ColorScheme esquema) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: esquema.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, color: esquema.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogoClase extends StatefulWidget {
  const _DialogoClase({this.inicial, required this.coaches});

  final Clase? inicial;
  final List<Usuario> coaches;

  @override
  State<_DialogoClase> createState() => _DialogoClaseState();
}

class _DialogoClaseState extends State<_DialogoClase> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _cupo;
  late final TextEditingController _sala;
  late int _dia;
  late String _hora;
  late int _duracion;
  String? _coachId;
  bool _activa = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.inicial;
    _nombre = TextEditingController(text: c?.nombre ?? '');
    _descripcion = TextEditingController(text: c?.descripcion ?? '');
    _cupo = TextEditingController(text: '${c?.cupoMax ?? 20}');
    _sala = TextEditingController(text: c?.sala ?? '');
    _dia = c?.diaSemana ?? 1;
    _hora = c?.hora ?? '18:00';
    _duracion = c?.duracionMin ?? 60;
    _coachId = c?.coachId;
    _activa = c?.activa ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _cupo.dispose();
    _sala.dispose();
    super.dispose();
  }

  Future<void> _elegirHora() async {
    final partes = _hora.split(':');
    final elegido = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(partes.first) ?? 18,
        minute: int.tryParse(partes.last) ?? 0,
      ),
    );
    if (elegido != null) {
      setState(() {
        _hora = '${elegido.hour.toString().padLeft(2, '0')}:'
            '${elegido.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() => _guardando = true);
    String nombreCoach = '';
    for (final u in widget.coaches) {
      if (u.id == _coachId) nombreCoach = u.nombreCompleto;
    }
    final clase = Clase(
      id: widget.inicial?.id ?? '',
      nombre: _nombre.text.trim(),
      descripcion: _descripcion.text.trim(),
      coachId: _coachId,
      coachNombre: nombreCoach,
      diaSemana: _dia,
      hora: _hora,
      duracionMin: _duracion,
      cupoMax: int.tryParse(_cupo.text) ?? 20,
      sala: _sala.text.trim(),
      activa: _activa,
    );
    try {
      await ClasesRepo.instancia.guardarClase(clase);
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
    return AlertDialog(
      title: Text(widget.inicial == null ? 'Nueva clase' : 'Editar clase'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formulario,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombre,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcion,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _coachId,
                  decoration: const InputDecoration(labelText: 'Entrenador'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Sin asignar')),
                    for (final u in widget.coaches)
                      DropdownMenuItem(value: u.id, child: Text(u.nombreCompleto)),
                  ],
                  onChanged: (v) => setState(() => _coachId = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _dia,
                        decoration: const InputDecoration(labelText: 'Día'),
                        items: [
                          for (var i = 1; i <= 7; i++)
                            DropdownMenuItem(value: i, child: Text(Clase.dias[i - 1])),
                        ],
                        onChanged: (v) => setState(() => _dia = v ?? 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _elegirHora,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Hora'),
                          child: Text(_hora),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cupo,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Plazas'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _duracion,
                        decoration:
                            const InputDecoration(labelText: 'Duración (min)'),
                        items: [
                          for (final m in [30, 45, 50, 60, 75, 90])
                            DropdownMenuItem(value: m, child: Text('$m')),
                        ],
                        onChanged: (v) => setState(() => _duracion = v ?? 60),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sala,
                  decoration: const InputDecoration(labelText: 'Sala'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Clase activa'),
                  value: _activa,
                  onChanged: (v) => setState(() => _activa = v),
                ),
              ],
            ),
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
