import 'package:flutter/material.dart';

import '../../core/error_fitcore.dart';
import '../../core/formato.dart';
import '../../datos/avisos_repo.dart';
import '../../modelos/aviso.dart';
import '../../widgets/comunes.dart';

/// Publicación y administración de avisos y novedades.
class AvisosAdmin extends StatefulWidget {
  const AvisosAdmin({super.key});

  @override
  State<AvisosAdmin> createState() => _AvisosAdminState();
}

class _AvisosAdminState extends State<AvisosAdmin> {
  late Future<List<Aviso>> _futuro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() {
      _futuro = AvisosRepo.instancia.listar();
    });
  }

  Future<void> _abrirFormulario([Aviso? inicial]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoAviso(inicial: inicial),
    );
    if (guardado == true) _cargar();
  }

  Future<void> _confirmarEliminar(Aviso aviso) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar aviso'),
        content: Text('¿Seguro que quieres eliminar "${aviso.titulo}"?'),
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
      await AvisosRepo.instancia.eliminar(aviso.id);
      _cargar();
      if (mounted) avisar(context, 'Aviso eliminado.');
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    }
  }

  Future<void> _alternarEstado(Aviso aviso) async {
    try {
      await AvisosRepo.instancia.activar(aviso.id, !aviso.activo);
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
        icon: const Icon(Icons.campaign_outlined),
        label: const Text('Nuevo aviso'),
      ),
      body: FutureBuilder<List<Aviso>>(
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
              icono: Icons.campaign_outlined,
              mensaje: 'No hay avisos publicados.',
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

  Widget _tarjeta(Aviso a) {
    final es = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Opacity(
          opacity: a.activo ? 1 : 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      a.titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (a.importante)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Importante',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                a.contenido,
                style: TextStyle(
                  height: 1.45,
                  color: es.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 15, color: es.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      Formato.fechaHora(a.fechaPublicacion),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: es.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    a.activo ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 15,
                    color: es.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    a.activo ? 'Publicado' : 'Oculto',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: es.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => _alternarEstado(a),
                    child: Text(a.activo ? 'Ocultar' : 'Publicar'),
                  ),
                  TextButton(
                    onPressed: () => _abrirFormulario(a),
                    child: const Text('Editar'),
                  ),
                  TextButton(
                    onPressed: () => _confirmarEliminar(a),
                    style: TextButton.styleFrom(foregroundColor: es.error),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogoAviso extends StatefulWidget {
  const _DialogoAviso({this.inicial});

  final Aviso? inicial;

  @override
  State<_DialogoAviso> createState() => _DialogoAvisoState();
}

class _DialogoAvisoState extends State<_DialogoAviso> {
  final _formulario = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _contenido = TextEditingController();
  bool _importante = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final ini = widget.inicial;
    if (ini != null) {
      _titulo.text = ini.titulo;
      _contenido.text = ini.contenido;
      _importante = ini.importante;
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _contenido.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final ini = widget.inicial;
      final aviso = Aviso(
        id: ini?.id ?? '',
        titulo: _titulo.text.trim(),
        contenido: _contenido.text.trim(),
        fechaPublicacion: ini?.fechaPublicacion,
        activo: ini?.activo ?? true,
        importante: _importante,
      );
      await AvisosRepo.instancia.guardar(aviso);
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
      title: Text(widget.inicial == null ? 'Nuevo aviso' : 'Editar aviso'),
      content: SingleChildScrollView(
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titulo,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contenido,
                decoration: const InputDecoration(labelText: 'Contenido'),
                maxLines: 5,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Marcar como importante'),
                value: _importante,
                onChanged: (v) => setState(() => _importante = v),
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
              : const Text('Publicar'),
        ),
      ],
    );
  }
}
