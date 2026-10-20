import 'package:flutter/material.dart';

import '../modelos/usuario.dart';

/// Color asociado a cada rol.
Color colorRol(Rol rol, ColorScheme esquema) {
  switch (rol) {
    case Rol.admin:
      return esquema.primary;
    case Rol.coach:
      const turquesa = Color(0xFF22D3EE);
      return turquesa;
    case Rol.socio:
      return esquema.tertiary;
  }
}

/// Selector segmentado de rol (Administrador / Instructor / Cliente).
class SelectorRol extends StatelessWidget {
  const SelectorRol({
    super.key,
    required this.valor,
    required this.onCambio,
    this.roles = const [Rol.admin, Rol.coach, Rol.socio],
  });

  final Rol valor;
  final ValueChanged<Rol> onCambio;
  final List<Rol> roles;

  IconData _icono(Rol rol) {
    switch (rol) {
      case Rol.admin:
        return Icons.admin_panel_settings_outlined;
      case Rol.coach:
        return Icons.sports_outlined;
      case Rol.socio:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: esquema.outline.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          for (final rol in roles)
            Expanded(
              child: GestureDetector(
                onTap: () => onCambio(rol),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: valor == rol ? esquema.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icono(rol),
                        size: 20,
                        color: valor == rol
                            ? esquema.onPrimary
                            : esquema.onSurfaceVariant,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rol.etiquetaAcceso,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: valor == rol
                              ? esquema.onPrimary
                              : esquema.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Avatar circular con las iniciales del usuario.
class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({super.key, required this.usuario, this.tamano = 44});

  final Usuario usuario;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: tamano / 2,
      backgroundColor: colorRol(usuario.rol, esquema).withValues(alpha: 0.16),
      child: Text(
        usuario.iniciales,
        style: TextStyle(
          color: colorRol(usuario.rol, esquema),
          fontWeight: FontWeight.w700,
          fontSize: tamano * 0.36,
        ),
      ),
    );
  }
}

/// Etiqueta compacta con el nombre del rol.
class EtiquetaRol extends StatelessWidget {
  const EtiquetaRol({super.key, required this.rol});

  final Rol rol;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final color = colorRol(rol, esquema);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rol.etiqueta,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Tarjeta de indicador para el panel.
class TarjetaEstadistica extends StatelessWidget {
  const TarjetaEstadistica({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    this.pie,
  });

  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final String? pie;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              valor,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              titulo,
              style: TextStyle(color: esquema.onSurfaceVariant, fontSize: 13),
            ),
            if (pie != null) ...[
              const SizedBox(height: 6),
              Text(
                pie!,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mensaje para listados sin datos.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox_outlined,
  });

  final String mensaje;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: esquema.outline),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(color: esquema.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Franja de error reutilizable en formularios.
class FranjaError extends StatelessWidget {
  const FranjaError({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: esquema.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: esquema.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(color: esquema.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra un SnackBar simple.
void avisar(BuildContext context, String mensaje, {bool error = false}) {
  final esquema = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? esquema.error : null,
      ),
    );
}
