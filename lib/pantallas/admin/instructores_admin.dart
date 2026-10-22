import 'package:flutter/material.dart';

import '../../core/error_fitcore.dart';
import '../../datos/clases_repo.dart';
import '../../datos/usuarios_repo.dart';
import '../../modelos/clase.dart';
import '../../modelos/usuario.dart';
import '../../widgets/comunes.dart';

/// Gestión de instructores del gimnasio.
class InstructoresAdmin extends StatefulWidget {
  const InstructoresAdmin({super.key});

  @override
  State<InstructoresAdmin> createState() => _InstructoresAdminState();
}

class _InstructoresAdminState extends State<InstructoresAdmin> {
  late Future<List<Usuario>> _futuro;
  List<Clase> _clases = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _futuro = UsuariosRepo.instancia.listarPorRol(Rol.coach);
    });
    try {
      _clases = await ClasesRepo.instancia.listarClases();
    } catch (_) {
      _clases = [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _abrirFormulario([Usuario? inicial]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoInstructor(inicial: inicial),
    );
    if (guardado == true) _cargar();
  }

  Future<void> _confirmarEliminar(Usuario instructor) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar instructor'),
        content: Text(
            '¿Seguro que quieres eliminar a ${instructor.nombreCompleto}?'),
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
      await UsuariosRepo.instancia.eliminar(instructor.id);
      _cargar();
      if (mounted) avisar(context, 'Instructor eliminado.');
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    }
  }

  Future<void> _cambiarEstado(Usuario instructor, bool activo) async {
    try {
      await UsuariosRepo.instancia.activar(instructor.id, activo);
      _cargar();
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Nuevo instructor'),
      ),
      body: FutureBuilder<List<Usuario>>(
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
              icono: Icons.sports_gymnastics_outlined,
              mensaje: 'No hay instructores registrados.',
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

  Widget _tarjeta(Usuario u) {
    final es = Theme.of(context).colorScheme;
    final asignadas =
        _clases.where((c) => c.coachId == u.id && c.activa).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarUsuario(usuario: u, tamano: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        u.correo,
                        style: TextStyle(
                          color: es.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: u.activo,
                  onChanged: (v) => _cambiarEstado(u, v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (u.telefono.isNotEmpty)
                  _chip(Icons.phone_outlined, u.telefono, es),
                if (u.especialidad != null && u.especialidad!.isNotEmpty)
                  _chip(Icons.star_outline, u.especialidad!, es),
                _chip(Icons.event_note_outlined,
                    '${asignadas.length} clases asignadas', es),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => _abrirFormulario(u),
                  child: const Text('Editar'),
                ),
                TextButton(
                  onPressed: () => _confirmarEliminar(u),
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

  Widget _chip(IconData icono, String texto, ColorScheme es) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: es.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: es.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, color: es.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogoInstructor extends StatefulWidget {
  const _DialogoInstructor({this.inicial});

  final Usuario? inicial;

  @override
  State<_DialogoInstructor> createState() => _DialogoInstructorState();
}

class _DialogoInstructorState extends State<_DialogoInstructor> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _especialidad = TextEditingController();
  final _clave = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final ini = widget.inicial;
    if (ini != null) {
      _nombre.text = ini.nombre;
      _apellidos.text = ini.apellidos;
      _correo.text = ini.correo;
      _telefono.text = ini.telefono;
      _especialidad.text = ini.especialidad ?? '';
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _correo.dispose();
    _telefono.dispose();
    _especialidad.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final ini = widget.inicial;
      if (ini == null) {
        await UsuariosRepo.instancia.crear(
          nombre: _nombre.text.trim(),
          apellidos: _apellidos.text.trim(),
          correo: _correo.text.trim(),
          telefono: _telefono.text.trim(),
          rol: Rol.coach,
          especialidad: _especialidad.text.trim().isEmpty
              ? null
              : _especialidad.text.trim(),
          clave: _clave.text.trim().isEmpty ? null : _clave.text.trim(),
        );
      } else {
        await UsuariosRepo.instancia.actualizar(
          ini.copyWith(
            nombre: _nombre.text.trim(),
            apellidos: _apellidos.text.trim(),
            correo: _correo.text.trim(),
            telefono: _telefono.text.trim(),
            especialidad: _especialidad.text.trim().isEmpty
                ? null
                : _especialidad.text.trim(),
          ),
        );
      }
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
    return AlertDialog(
      title: Text(es ? 'Editar instructor' : 'Nuevo instructor'),
      content: SingleChildScrollView(
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: _campo(_nombre, 'Nombre')),
                  const SizedBox(width: 12),
                  Expanded(child: _campo(_apellidos, 'Apellidos')),
                ],
              ),
              const SizedBox(height: 12),
              _campo(_correo, 'Correo electrónico', email: true),
              const SizedBox(height: 12),
              _campo(_telefono, 'Teléfono', obligatorio: false),
              const SizedBox(height: 12),
              _campo(_especialidad, 'Especialidad (ej. Spinning)',
                  obligatorio: false),
              if (!es) ...[
                const SizedBox(height: 12),
                _campo(_clave, 'Contraseña de acceso', obligatorio: false),
              ],
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

  Widget _campo(
    TextEditingController controlador,
    String etiqueta, {
    bool email = false,
    bool obligatorio = true,
  }) {
    return TextFormField(
      controller: controlador,
      keyboardType: email ? TextInputType.emailAddress : null,
      decoration: InputDecoration(labelText: etiqueta),
      validator: (v) {
        final t = (v ?? '').trim();
        if (obligatorio && t.isEmpty) return 'Campo obligatorio';
        if (email && t.isNotEmpty && !t.contains('@')) return 'Correo no válido';
        return null;
      },
    );
  }
}
