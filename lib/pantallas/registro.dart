import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estado/sesion.dart';
import '../modelos/usuario.dart';
import '../widgets/comunes.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  final _confirmar = TextEditingController();
  bool _verClave = false;
  Rol _rol = Rol.socio;

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _telefono.dispose();
    _correo.dispose();
    _clave.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();
    if (!_formulario.currentState!.validate()) return;
    final ok = await context.read<Sesion>().registrar(
          nombre: _nombre.text,
          apellidos: _apellidos.text,
          telefono: _telefono.text,
          correo: _correo.text,
          clave: _clave.text,
          rol: _rol,
        );
    if (ok && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<Sesion>();
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (sesion.error != null) ...[
                      FranjaError(mensaje: sesion.error!),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Tipo de cuenta',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectorRol(
                      valor: _rol,
                      onCambio: (r) => setState(() => _rol = r),
                    ),
                    const SizedBox(height: 20),
                    _campo(_nombre, 'Nombre', Icons.person_outline),
                    const SizedBox(height: 16),
                    _campo(_apellidos, 'Apellidos', Icons.person_outline),
                    const SizedBox(height: 16),
                    _campo(
                      _telefono,
                      'Teléfono',
                      Icons.phone_outlined,
                      tipo: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _campo(
                      _correo,
                      'Correo electrónico',
                      Icons.mail_outline,
                      tipo: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clave,
                      obscureText: !_verClave,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _verClave
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(() => _verClave = !_verClave),
                        ),
                      ),
                      validator: (v) {
                        if ((v ?? '').length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmar,
                      obscureText: !_verClave,
                      decoration: const InputDecoration(
                        labelText: 'Repetir contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) {
                        if (v != _clave.text) return 'Las contraseñas no coinciden';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: sesion.cargando ? null : _registrar,
                      child: sesion.cargando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : const Text('Registrarme'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController controlador,
    String etiqueta,
    IconData icono, {
    TextInputType? tipo,
  }) {
    return TextFormField(
      controller: controlador,
      keyboardType: tipo,
      decoration: InputDecoration(labelText: etiqueta, prefixIcon: Icon(icono)),
      validator: (v) =>
          (v ?? '').trim().isEmpty ? 'Campo obligatorio' : null,
    );
  }
}
