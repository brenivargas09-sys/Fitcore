import 'package:flutter/material.dart';

import '../../core/config_supabase.dart';
import '../../core/error_fitcore.dart';
import '../../datos/usuarios_repo.dart';
import '../../modelos/usuario.dart';
import '../../widgets/comunes.dart';

class UsuariosAdmin extends StatefulWidget {
  const UsuariosAdmin({super.key});

  @override
  State<UsuariosAdmin> createState() => _UsuariosAdminState();
}

class _UsuariosAdminState extends State<UsuariosAdmin> {
  late Future<List<Usuario>> _futuro;
  final _busqueda = TextEditingController();
  Rol? _filtro = Rol.socio;

  @override
  void initState() {
    super.initState();
    _futuro = UsuariosRepo.instancia.listar();
    _busqueda.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _futuro = UsuariosRepo.instancia.listar();
    });
  }

  Future<void> _abrirFormulario([Usuario? inicial]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoUsuario(inicial: inicial),
    );
    if (guardado == true) _recargar();
  }

  Future<void> _confirmarEliminar(Usuario usuario) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Seguro que quieres eliminar a ${usuario.nombreCompleto}?'),
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
      await UsuariosRepo.instancia.eliminar(usuario.id);
      _recargar();
      if (mounted) avisar(context, 'Usuario eliminado.');
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    }
  }

  Future<void> _cambiarRol(Usuario usuario, Rol rol) async {
    try {
      await UsuariosRepo.instancia.cambiarRol(usuario.id, rol);
      _recargar();
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    }
  }

  Future<void> _cambiarEstado(Usuario usuario, bool activo) async {
    try {
      await UsuariosRepo.instancia.activar(usuario.id, activo);
      _recargar();
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
        label: const Text('Nuevo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              children: [
                TextField(
                  controller: _busqueda,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre o correo',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chipFiltro('Todos', null),
                      for (final r in Rol.values) _chipFiltro(r.etiqueta, r),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Usuario>>(
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
                final lista = _filtrar(snapshot.data!);
                if (lista.isEmpty) {
                  return const EstadoVacio(
                    icono: Icons.person_search_outlined,
                    mensaje: 'No se encontraron usuarios.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _fila(lista[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Usuario> _filtrar(List<Usuario> usuarios) {
    final texto = _busqueda.text.trim().toLowerCase();
    return usuarios.where((u) {
      final coincideTexto = texto.isEmpty ||
          u.nombreCompleto.toLowerCase().contains(texto) ||
          u.correo.toLowerCase().contains(texto);
      final coincideRol = _filtro == null || u.rol == _filtro;
      return coincideTexto && coincideRol;
    }).toList();
  }

  Widget _chipFiltro(String etiqueta, Rol? rol) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(etiqueta),
        selected: _filtro == rol,
        onSelected: (_) => setState(() => _filtro = rol),
      ),
    );
  }

  Widget _fila(Usuario u) {
    final esquema = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            AvatarUsuario(usuario: u),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        u.nombreCompleto,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                      EtiquetaRol(rol: u.rol),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    u.correo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: esquema.onSurfaceVariant, fontSize: 13),
                  ),
                  if (u.especialidad != null && u.especialidad!.isNotEmpty)
                    Text(
                      'Especialidad: ${u.especialidad}',
                      style: TextStyle(color: esquema.onSurfaceVariant, fontSize: 12),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Switch(
                  value: u.activo,
                  onChanged: (v) => _cambiarEstado(u, v),
                ),
                Text(
                  u.activo ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontSize: 11,
                    color: u.activo ? esquema.primary : esquema.outline,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (valor) {
                if (valor == 'editar') {
                  _abrirFormulario(u);
                } else if (valor == 'eliminar') {
                  _confirmarEliminar(u);
                } else {
                  _cambiarRol(u, Rol.desde(valor.replaceFirst('rol:', '')));
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                  ),
                ),
                const PopupMenuDivider(),
                for (final r in Rol.values)
                  CheckedPopupMenuItem(
                    value: 'rol:${r.valor}',
                    checked: u.rol == r,
                    child: Text(r.etiqueta),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(
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
}

/// Alta y edicion de usuarios desde el panel.
class _DialogoUsuario extends StatefulWidget {
  const _DialogoUsuario({this.inicial});

  final Usuario? inicial;

  @override
  State<_DialogoUsuario> createState() => _DialogoUsuarioState();
}

class _DialogoUsuarioState extends State<_DialogoUsuario> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _apellidos;
  late final TextEditingController _correo;
  late final TextEditingController _telefono;
  late final TextEditingController _especialidad;
  late final TextEditingController _clave;
  late Rol _rol;
  bool _guardando = false;

  bool get _esEdicion => widget.inicial != null;

  @override
  void initState() {
    super.initState();
    final u = widget.inicial;
    _nombre = TextEditingController(text: u?.nombre ?? '');
    _apellidos = TextEditingController(text: u?.apellidos ?? '');
    _correo = TextEditingController(text: u?.correo ?? '');
    _telefono = TextEditingController(text: u?.telefono ?? '');
    _especialidad = TextEditingController(text: u?.especialidad ?? '');
    _clave = TextEditingController();
    _rol = u?.rol ?? Rol.socio;
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
      if (_esEdicion) {
        await UsuariosRepo.instancia.actualizar(
          widget.inicial!.copyWith(
            nombre: _nombre.text,
            apellidos: _apellidos.text,
            correo: _correo.text,
            telefono: _telefono.text,
            rol: _rol,
            especialidad: _rol == Rol.coach ? _especialidad.text : null,
          ),
        );
      } else {
        await UsuariosRepo.instancia.crear(
          nombre: _nombre.text,
          apellidos: _apellidos.text,
          correo: _correo.text,
          telefono: _telefono.text,
          rol: _rol,
          especialidad: _rol == Rol.coach ? _especialidad.text : null,
          clave: _clave.text,
        );
      }
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
    final mostrarClave = !_esEdicion && !ConfigSupabase.configurado;
    return AlertDialog(
      title: Text(_esEdicion ? 'Editar usuario' : 'Nuevo usuario'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formulario,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campo(_nombre, 'Nombre'),
                const SizedBox(height: 12),
                _campo(_apellidos, 'Apellidos'),
                const SizedBox(height: 12),
                _campo(_correo, 'Correo', email: true),
                const SizedBox(height: 12),
                _campo(
                  _telefono,
                  'Teléfono',
                  tipo: TextInputType.phone,
                  obligatorio: false,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Rol>(
                  initialValue: _rol,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: [
                    for (final r in Rol.values)
                      DropdownMenuItem(value: r, child: Text(r.etiqueta)),
                  ],
                  onChanged: (v) => setState(() => _rol = v ?? Rol.socio),
                ),
                if (_rol == Rol.coach) ...[
                  const SizedBox(height: 12),
                  _campo(_especialidad, 'Especialidad', obligatorio: false),
                ],
                if (mostrarClave) ...[
                  const SizedBox(height: 12),
                  _campo(_clave, 'Contraseña de acceso', obligatorio: false),
                ],
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

  Widget _campo(
    TextEditingController controlador,
    String etiqueta, {
    bool email = false,
    bool obligatorio = true,
    TextInputType? tipo,
  }) {
    return TextFormField(
      controller: controlador,
      keyboardType: tipo ?? (email ? TextInputType.emailAddress : null),
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
