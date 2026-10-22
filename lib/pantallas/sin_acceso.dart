import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estado/sesion.dart';
import '../widgets/comunes.dart';

/// Pantalla para usuarios sin permisos de administración.
class SinAcceso extends StatelessWidget {
  const SinAcceso({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<Sesion>();
    final usuario = sesion.usuario;
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitCore'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<Sesion>().salir(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (usuario != null) AvatarUsuario(usuario: usuario, tamano: 72),
                const SizedBox(height: 20),
                Text(
                  usuario?.nombreCompleto ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                if (usuario != null) ...[
                  const SizedBox(height: 6),
                  EtiquetaRol(rol: usuario.rol),
                ],
                const SizedBox(height: 20),
                Text(
                  'Tu cuenta no tiene acceso al panel administrativo. '
                  'Pide a un administrador que revise tu rol.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: esquema.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => context.read<Sesion>().salir(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
