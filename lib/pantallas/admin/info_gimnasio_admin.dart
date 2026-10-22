import 'package:flutter/material.dart';

import '../../core/error_fitcore.dart';
import '../../datos/info_gimnasio_repo.dart';
import '../../modelos/info_gimnasio.dart';
import '../../widgets/comunes.dart';

/// Edición de la información general del gimnasio Ciclic Studio.
class InfoGimnasioAdmin extends StatefulWidget {
  const InfoGimnasioAdmin({super.key});

  @override
  State<InfoGimnasioAdmin> createState() => _InfoGimnasioAdminState();
}

class _InfoGimnasioAdminState extends State<InfoGimnasioAdmin> {
  late Future<InfoGimnasio> _futuro;
  final _formulario = GlobalKey<FormState>();

  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  final _horarios = TextEditingController();
  final _servicios = TextEditingController();
  final _imagen = TextEditingController();

  bool _cargado = false;
  bool _guardando = false;
  InfoGimnasio? _actual;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<InfoGimnasio> _cargar() async {
    final info = await InfoGimnasioRepo.instancia.obtener();
    _actual = info;
    _nombre.text = info.nombre;
    _descripcion.text = info.descripcion;
    _direccion.text = info.direccion;
    _telefono.text = info.telefono;
    _horarios.text = info.horariosAtencion;
    _servicios.text = info.servicios;
    _imagen.text = info.imagenUrl;
    _cargado = true;
    return info;
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final info = (_actual ?? const InfoGimnasio(id: '')).copyWith(
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        direccion: _direccion.text.trim(),
        telefono: _telefono.text.trim(),
        horariosAtencion: _horarios.text.trim(),
        servicios: _servicios.text.trim(),
        imagenUrl: _imagen.text.trim(),
      );
      await InfoGimnasioRepo.instancia.guardar(info);
      if (mounted) avisar(context, 'Información del gimnasio actualizada.');
    } on ErrorFitCore catch (e) {
      if (mounted) avisar(context, e.mensaje, error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _direccion.dispose();
    _telefono.dispose();
    _horarios.dispose();
    _servicios.dispose();
    _imagen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<InfoGimnasio>(
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
          if (!_cargado) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _encabezado(),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formulario,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _campo(_nombre, 'Nombre del establecimiento'),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _descripcion,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        _campo(_direccion, 'Dirección'),
                        const SizedBox(height: 14),
                        _campo(_telefono, 'Teléfono de contacto',
                            tipo: TextInputType.phone),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _horarios,
                          decoration: const InputDecoration(
                            labelText: 'Horarios de atención',
                            helperText: 'Usa saltos de línea para separar días',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _servicios,
                          decoration: const InputDecoration(
                            labelText: 'Servicios de aeróbicos',
                            helperText:
                                'Ej: Spinning, Zumba, Yoga, Funcional',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 14),
                        _campo(_imagen, 'URL de fotografía de instalaciones',
                            tipo: TextInputType.url, obligatorio: false),
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          onPressed: _guardando ? null : _guardar,
                          icon: _guardando
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.4),
                                )
                              : const Icon(Icons.save_outlined),
                          label: const Text('Guardar cambios'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _encabezado() {
    final es = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información del gimnasio',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Estos datos se muestran a los clientes en la aplicación.',
          style: TextStyle(color: es.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _campo(
    TextEditingController controlador,
    String etiqueta, {
    TextInputType? tipo,
    bool obligatorio = true,
  }) {
    return TextFormField(
      controller: controlador,
      keyboardType: tipo,
      decoration: InputDecoration(labelText: etiqueta),
      validator: (v) {
        if (!obligatorio) return null;
        return (v ?? '').trim().isEmpty ? 'Campo obligatorio' : null;
      },
    );
  }
}
