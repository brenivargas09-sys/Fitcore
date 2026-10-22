import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/tema.dart';
import '../../estado/control_tema.dart';
import '../../estado/sesion.dart';
import '../../widgets/comunes.dart';
import 'avisos_admin.dart';
import 'clases_admin.dart';
import 'configuracion_admin.dart';
import 'info_gimnasio_admin.dart';
import 'inicio_admin.dart';
import 'instructores_admin.dart';
import 'membresias_admin.dart';
import 'pagos_admin.dart';
import 'reportes_admin.dart';
import 'rutinas_admin.dart';
import 'usuarios_admin.dart';

/// Contenedor del panel administrativo con navegacion lateral adaptable.
class PanelAdmin extends StatefulWidget {
  const PanelAdmin({super.key});

  @override
  State<PanelAdmin> createState() => _PanelAdminState();
}

class _PanelAdminState extends State<PanelAdmin> {
  int _indice = 0;
  final _scrollMenu = ScrollController();

  static const _destinos = <_Destino>[
    _Destino('Inicio', Icons.dashboard_outlined, Icons.dashboard),
    _Destino('Clientes', Icons.group_outlined, Icons.group),
    _Destino('Instructores', Icons.sports_gymnastics_outlined,
        Icons.sports_gymnastics),
    _Destino('Clases y horarios', Icons.event_note_outlined, Icons.event_note),
    _Destino('Rutinas', Icons.fitness_center_outlined, Icons.fitness_center),
    _Destino('Membresías', Icons.card_membership_outlined,
        Icons.card_membership),
    _Destino('Pagos', Icons.payments_outlined, Icons.payments),
    _Destino('Avisos', Icons.campaign_outlined, Icons.campaign),
    _Destino('Información', Icons.storefront_outlined, Icons.storefront),
    _Destino('Reportes', Icons.bar_chart_outlined, Icons.bar_chart),
    _Destino('Configuración', Icons.settings_outlined, Icons.settings),
  ];

  Widget get _cuerpo {
    switch (_indice) {
      case 0:
        return const InicioAdmin();
      case 1:
        return const UsuariosAdmin();
      case 2:
        return const InstructoresAdmin();
      case 3:
        return const ClasesAdmin();
      case 4:
        return const RutinasAdmin();
      case 5:
        return const MembresiasAdmin();
      case 6:
        return const PagosAdmin();
      case 7:
        return const AvisosAdmin();
      case 8:
        return const InfoGimnasioAdmin();
      case 9:
        return const ReportesAdmin();
      default:
        return const ConfiguracionAdmin();
    }
  }

  @override
  void dispose() {
    _scrollMenu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final amplio = ancho >= 900;
    final es = Theme.of(context).colorScheme;

    final appBar = AppBar(
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _destinos[_indice].titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 1),
          Text(
            'Panel de administración',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: es.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: const [
        _BotonTema(),
        SizedBox(width: 4),
        _BotonPerfil(),
        SizedBox(width: 12),
      ],
    );

    if (amplio) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            _panelLateral(context),
            const VerticalDivider(width: 1),
            Expanded(child: _cuerpo),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      drawer: Drawer(
        elevation: 0,
        child: SafeArea(
          child: Column(
            children: [
              _encabezadoCuenta(context),
              Expanded(child: _listaNavegacion(context, cerrarAlTocar: true)),
              const Divider(height: 1),
              _PieCuenta(
                  oscuro: Theme.of(context).brightness == Brightness.dark),
            ],
          ),
        ),
      ),
      body: _cuerpo,
    );
  }

  /// Navegacion fija para pantallas anchas (scrollable para alojar 11 modulos).
  Widget _panelLateral(BuildContext context) {
    final es = Theme.of(context).colorScheme;
    return Container(
      width: 276,
      decoration: BoxDecoration(
        color: es.surface,
        border: Border(
          right: BorderSide(color: es.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: _CabeceraMarca(oscuro: Theme.of(context).brightness ==
                Brightness.dark),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MÓDULOS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: es.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(child: _listaNavegacion(context, cerrarAlTocar: false)),
          const Divider(height: 1),
          _PieCuenta(oscuro: Theme.of(context).brightness == Brightness.dark),
        ],
      ),
    );
  }

  Widget _listaNavegacion(BuildContext context, {required bool cerrarAlTocar}) {
    final es = Theme.of(context).colorScheme;
    return ListView.builder(
      controller: _scrollMenu,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _destinos.length,
      itemBuilder: (context, i) {
        final d = _destinos[i];
        final seleccionado = i == _indice;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: seleccionado
                ? TemaFitCore.azul.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() => _indice = i);
                if (cerrarAlTocar) Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: seleccionado
                        ? TemaFitCore.azul.withValues(alpha: 0.35)
                        : Colors.transparent,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                child: Row(
                  children: [
                    Icon(
                      seleccionado ? d.iconoActivo : d.icono,
                      size: 21,
                      color: seleccionado ? TemaFitCore.azul : es.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        d.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              seleccionado ? FontWeight.w700 : FontWeight.w500,
                          color: seleccionado ? TemaFitCore.azul : es.onSurface,
                        ),
                      ),
                    ),
                    if (seleccionado)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: TemaFitCore.azul,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _encabezadoCuenta(BuildContext context) {
    final sesion = context.read<Sesion>();
    return UserAccountsDrawerHeader(
      currentAccountPicture: sesion.usuario == null
          ? const CircleAvatar(child: Icon(Icons.person))
          : AvatarUsuario(usuario: sesion.usuario!, tamano: 60),
      accountName: Text(sesion.usuario?.nombreCompleto ?? ''),
      accountEmail: Text(sesion.usuario?.correo ?? ''),
    );
  }
}

/// Marca del panel con degradado y brillo sutil.
class _CabeceraMarca extends StatelessWidget {
  const _CabeceraMarca({required this.oscuro});

  final bool oscuro;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TemaFitCore.azul, TemaFitCore.cian],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: TemaFitCore.azul.withValues(alpha: oscuro ? 0.35 : 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          _LogoFitCore(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FitCore',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Gimnasio · Administración',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pie del panel lateral con la cuenta y el interruptor de tema.
class _PieCuenta extends StatelessWidget {
  const _PieCuenta({required this.oscuro});

  final bool oscuro;

  @override
  Widget build(BuildContext context) {
    final es = Theme.of(context).colorScheme;
    final sesion = context.watch<Sesion>();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          sesion.usuario == null
              ? CircleAvatar(radius: 20, backgroundColor: es.primaryContainer,
                  child: Icon(Icons.person, color: es.onPrimaryContainer))
              : AvatarUsuario(usuario: sesion.usuario!, tamano: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sesion.usuario?.nombreCompleto ?? 'Cuenta',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Administrador',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: es.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const _BotonTema(),
        ],
      ),
    );
  }
}

class _BotonTema extends StatelessWidget {
  const _BotonTema();

  @override
  Widget build(BuildContext context) {
    final control = context.watch<ControlTema>();
    final es = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: control.esOscuro ? 'Modo claro' : 'Modo oscuro',
      onPressed: control.alternar,
      style: IconButton.styleFrom(
        backgroundColor: es.surfaceContainerHighest.withValues(alpha: 0.6),
        foregroundColor: es.onSurfaceVariant,
      ),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => RotationTransition(
          turns: anim,
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Icon(
          control.esOscuro
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          key: ValueKey(control.esOscuro),
          size: 20,
        ),
      ),
    );
  }
}

class _BotonPerfil extends StatelessWidget {
  const _BotonPerfil();

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<Sesion>();
    final es = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      tooltip: 'Cuenta',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (valor) {
        if (valor == 'salir') {
          context.read<Sesion>().salir();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: sesion.usuario == null
                ? const SizedBox.shrink()
                : AvatarUsuario(usuario: sesion.usuario!, tamano: 40),
            title: Text(sesion.usuario?.nombreCompleto ?? ''),
            subtitle: Text(sesion.usuario?.correo ?? ''),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'salir',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout),
            title: Text('Cerrar sesión'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: es.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: sesion.usuario == null
              ? CircleAvatar(radius: 17, child: const Icon(Icons.person, size: 20))
              : AvatarUsuario(usuario: sesion.usuario!, tamano: 36),
        ),
      ),
    );
  }
}

class _LogoFitCore extends StatelessWidget {
  const _LogoFitCore();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: const Icon(Icons.fitness_center, color: Colors.white, size: 24),
    );
  }
}

class _Destino {
  const _Destino(this.titulo, this.icono, this.iconoActivo);

  final String titulo;
  final IconData icono;
  final IconData iconoActivo;
}
