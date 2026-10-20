import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../estado/sesion.dart';
import '../../modelos/usuario.dart';
import '../../widgets/comunes.dart';

/// Opciones de configuración de la cuenta y de la aplicación.
class ConfiguracionAdmin extends StatelessWidget {
  const ConfiguracionAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = context.read<Sesion>();
    final usuario = sesion.usuario;
    final es = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Configuración',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Tu cuenta, permisos y estado de la aplicación.',
            style: TextStyle(color: es.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          if (usuario != null) _cuenta(context, usuario),
          const SizedBox(height: 16),
          _estadoSistema(context, sesion),
          const SizedBox(height: 16),
          _permisos(context),
          const SizedBox(height: 24),
          _cerrarSesion(context, sesion),
        ],
      ),
    );
  }

  Widget _cuenta(BuildContext context, Usuario usuario) {
    final es = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            AvatarUsuario(usuario: usuario, tamano: 64),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    usuario.correo,
                    style: TextStyle(color: es.onSurfaceVariant),
                  ),
                  if (usuario.telefono.isNotEmpty)
                    Text(
                      usuario.telefono,
                      style: TextStyle(color: es.onSurfaceVariant),
                    ),
                  const SizedBox(height: 8),
                  EtiquetaRol(rol: usuario.rol),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoSistema(BuildContext context, Sesion sesion) {
    final es = Theme.of(context).colorScheme;
    final usaSupabase = sesion.usaSupabase;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Text(
              'Estado del sistema',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            leading: Icon(
              usaSupabase ? Icons.cloud_done_outlined : Icons.storage_outlined,
              color: usaSupabase ? const Color(0xFF2E9E5B) : es.primary,
            ),
            title: const Text('Origen de los datos'),
            subtitle: Text(
              usaSupabase
                  ? 'Conectado a Supabase (nube)'
                  : 'Modo demo con almacenamiento local',
            ),
            trailing: Chip(
              label: Text(usaSupabase ? 'Supabase' : 'Demo'),
            ),
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.verified_user_outlined),
            title: Text('Rol con acceso'),
            subtitle: Text('Administrador · acceso completo al panel'),
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Versión'),
            subtitle: Text('FitCore 1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _permisos(BuildContext context) {
    final es = Theme.of(context).colorScheme;
    const descripciones = {
      Rol.admin:
          'Gestiona clientes, instructores, rutinas, horarios, membresías, pagos, avisos y reportes.',
      Rol.coach:
          'Consulta sus clases y rutinas asignadas. No administra cuentas ni horarios generales.',
      Rol.socio:
          'Consulta horarios, rutinas, su membresía y los avisos del gimnasio.',
    };
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Text(
              'Permisos por rol',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          for (final rol in Rol.values) ...[
            ListTile(
              leading: Icon(
                switch (rol) {
                  Rol.admin => Icons.admin_panel_settings_outlined,
                  Rol.coach => Icons.sports_outlined,
                  Rol.socio => Icons.person_outline,
                },
                color: colorRol(rol, es),
              ),
              title: Text(rol.etiqueta),
              subtitle: Text(descripciones[rol]!),
            ),
            if (rol != Rol.values.last) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _cerrarSesion(BuildContext context, Sesion sesion) {
    final es = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cerrar sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: es.error,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Finaliza tu sesión de forma segura en este dispositivo.',
              style: TextStyle(color: es.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _confirmarSalida(context, sesion),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(foregroundColor: es.error),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarSalida(BuildContext context, Sesion sesion) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (ok == true) await sesion.salir();
  }
}
