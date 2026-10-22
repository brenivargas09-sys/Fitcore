import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/rutas.dart';
import '../core/tema.dart';
import '../estado/sesion.dart';
import '../modelos/usuario.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  bool _verClave = false;
  Rol _rol = Rol.admin;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();
    if (!_formulario.currentState!.validate()) return;
    await context.read<Sesion>().entrar(
          _correo.text,
          _clave.text,
          rolEsperado: _rol,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Escritorio / tableta ancha: dos columnas (marca + formulario).
    // Movil: tarjeta centrada sobre la imagen de fondo.
    final dims = MediaQuery.sizeOf(context);
    final amplio = dims.width >= 980;
    final estrecho = dims.width < 380;
    final verticalCorto = dims.height < 640;

    // La tarjeta es siempre oscura; sin este tema los campos de texto salen
    // con relleno blanco y el texto escrito (blanco) queda invisible.
    return Theme(
      data: TemaFitCore.oscuro(),
      child: Scaffold(
        backgroundColor: TemaFitCore.carbon,
        body: Stack(
          children: [
            const Positioned.fill(child: _FondoImagen()),
            const Positioned.fill(child: _Fondo()),
            if (!amplio) const Positioned.fill(child: _MarcaAgua()),
            Positioned.fill(
              child: SafeArea(
                child: _zonaFormulario(
                  sesion: context.watch<Sesion>(),
                  amplio: amplio,
                  estrecho: estrecho,
                  verticalCorto: verticalCorto,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zonaFormulario({
    required Sesion sesion,
    required bool amplio,
    required bool estrecho,
    required bool verticalCorto,
  }) {
    if (amplio) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: estrecho ? 40 : 64,
          vertical: verticalCorto ? 24 : 40,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: _ZonaMarca()),
            const SizedBox(width: 56),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _contenido(
                  sesion,
                  estrecho: estrecho,
                  verticalCorto: verticalCorto,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: estrecho ? 16 : 24,
          vertical: verticalCorto ? 20 : 36,
        ),
        child: _contenido(
          sesion,
          estrecho: estrecho,
          verticalCorto: verticalCorto,
        ),
      ),
    );
  }

  /// Tarjeta de acceso, enlace de registro y pie de pagina.
  Widget _contenido(
    Sesion sesion, {
    required bool estrecho,
    required bool verticalCorto,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: _EntradaAnimada(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TarjetaFormulario(
              padding: estrecho ? 22 : 32,
              child: Form(
                key: _formulario,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _cabecera(compacto: verticalCorto),
                    SizedBox(height: verticalCorto ? 14 : 22),
                    _etiquetaSeccion('Ingresar como'),
                    const SizedBox(height: 10),
                    _selectorRol(),
                    const SizedBox(height: 20),
                    if (sesion.error != null) ...[
                      _franjaError(sesion.error!),
                      const SizedBox(height: 16),
                    ],
                    _campoCorreo(),
                    const SizedBox(height: 14),
                    _campoClave(),
                    const SizedBox(height: 18),
                    _BotonIngresar(
                      cargando: sesion.cargando,
                      onTap: _entrar,
                    ),
                    if (!verticalCorto) ...[
                      const SizedBox(height: 18),
                      _notaSeguridad(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _pieRegistro(),
            const SizedBox(height: 18),
            Text(
              '© 2026 FitCore · Todos los derechos reservados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecera({required bool compacto}) {
    return Column(
      children: [
        _LogoFitCore(tamano: compacto ? 50 : 62),
        SizedBox(height: compacto ? 14 : 20),
        _insignia(),
        SizedBox(height: compacto ? 12 : 18),
        const Text(
          'Bienvenido de nuevo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para acceder al panel de administración.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        if (!compacto) ...[
          const SizedBox(height: 24),
          _divisor(),
        ],
      ],
    );
  }

  Widget _insignia() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: TemaFitCore.azul.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: TemaFitCore.azul.withValues(alpha: 0.28)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_outlined, size: 14, color: TemaFitCore.cian),
            const SizedBox(width: 7),
            Text(
              'ACCESO ADMINISTRATIVO',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divisor() {
    return Row(
      children: [
        Expanded(child: _linea()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.lock_outline,
            size: 14,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        Expanded(child: _linea()),
      ],
    );
  }

  Widget _linea() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.12),
          ],
        ),
      ),
    );
  }

  Widget _etiquetaSeccion(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: Colors.white.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  Widget _selectorRol() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          for (final rol in const [Rol.admin, Rol.coach, Rol.socio])
            Expanded(
              child: _OpcionRol(
                rol: rol,
                seleccionado: _rol == rol,
                onTap: () => setState(() => _rol = rol),
              ),
            ),
        ],
      ),
    );
  }

  Widget _campoCorreo() {
    return TextFormField(
      controller: _correo,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'tu@correo.com',
        prefixIcon: Icon(Icons.mail_outline),
      ),
      validator: (v) {
        final t = (v ?? '').trim();
        if (t.isEmpty) return 'Escribe tu correo';
        if (!t.contains('@') || !t.contains('.')) return 'Correo no válido';
        return null;
      },
    );
  }

  Widget _campoClave() {
    return TextFormField(
      controller: _clave,
      obscureText: !_verClave,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _entrar(),
      style: const TextStyle(color: Colors.white),
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
        if ((v ?? '').isEmpty) return 'Escribe tu contraseña';
        if (v!.length < 6) return 'Mínimo 6 caracteres';
        return null;
      },
    );
  }

  Widget _notaSeguridad() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 14,
          color: Colors.white.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            'Conexión segura y protegida',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pieRegistro() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, Rutas.registro),
          child: const Text('Crear cuenta'),
        ),
      ],
    );
  }

  Widget _franjaError(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFB7185), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(mensaje, style: const TextStyle(color: Color(0xFFFDA4AF))),
          ),
        ],
      ),
    );
  }

}

/// Opción de rol dentro del selector segmentado.
class _OpcionRol extends StatelessWidget {
  const _OpcionRol({
    required this.rol,
    required this.seleccionado,
    required this.onTap,
  });

  final Rol rol;
  final bool seleccionado;
  final VoidCallback onTap;

  IconData get _icono {
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: seleccionado
              ? const LinearGradient(
                  colors: [TemaFitCore.azul, TemaFitCore.cian],
                )
              : null,
          borderRadius: BorderRadius.circular(11),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                    color: TemaFitCore.azul.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icono,
              size: 20,
              color: seleccionado
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 6),
            Text(
              rol.etiquetaAcceso,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: seleccionado
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Foto de gimnasio de fondo con capa oscura azulada.
class _FondoImagen extends StatelessWidget {
  const _FondoImagen();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/gym_bg.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xB306101E),
                Color(0xCC0A0F1C),
                Color(0xE604060B),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Fondo premium: resplandores en movimiento, partículas flotantes,
/// cuadrícula tenue y viñeta.
class _Fondo extends StatefulWidget {
  const _Fondo();

  @override
  State<_Fondo> createState() => _FondoState();
}

class _FondoState extends State<_Fondo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _control;

  @override
  void initState() {
    super.initState();
    _control = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _control,
      builder: (context, _) {
        final t = _control.value;
        return Stack(
          children: [
            _Brillo(
              color: const Color(0xFF2E7BFF),
              alignment: Alignment(-0.85 + t * 0.25, -0.95 + t * 0.18),
              tamano: 0.9,
              intensidad: 0.5,
            ),
            _Brillo(
              color: const Color(0xFF22D3EE),
              alignment: Alignment(0.9 - t * 0.25, 0.95 - t * 0.2),
              tamano: 0.8,
              intensidad: 0.34,
            ),
            _Brillo(
              color: const Color(0xFF6D5BFF),
              alignment: Alignment(0.95, -0.25 + t * 0.25),
              tamano: 0.65,
              intensidad: 0.26,
            ),
            _Particulas(progreso: t),
            const Positioned.fill(
              child: CustomPaint(painter: _PatronCuadricula()),
            ),
            const Positioned.fill(child: _Vineta()),
          ],
        );
      },
    );
  }
}

/// Resplandor circular difuminado.
class _Brillo extends StatelessWidget {
  const _Brillo({
    required this.color,
    required this.alignment,
    required this.tamano,
    required this.intensidad,
  });

  final Color color;
  final Alignment alignment;
  final double tamano;
  final double intensidad;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: FractionallySizedBox(
          widthFactor: tamano,
          heightFactor: tamano,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: intensidad),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Puntos de luz que flotan lentamente hacia arriba.
class _Particulas extends StatelessWidget {
  const _Particulas({required this.progreso});

  final double progreso;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _ParticulasPainter(progreso: progreso)),
    );
  }
}

class _ParticulasPainter extends CustomPainter {
  _ParticulasPainter({required this.progreso});

  final double progreso;

  static final List<_Punto> _puntos = _generar();

  static List<_Punto> _generar() {
    final r = math.Random(7);
    return List.generate(48, (_) {
      return _Punto(
        x: r.nextDouble(),
        y: r.nextDouble(),
        radio: 0.6 + r.nextDouble() * 1.8,
        velocidad: 0.15 + r.nextDouble() * 0.5,
        fase: r.nextDouble(),
        azul: r.nextBool(),
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _puntos) {
      var y = (p.y - progreso * p.velocidad) % 1.0;
      if (y < 0) y += 1.0;
      final base = p.azul
          ? const Color(0xFF4C8DFF)
          : const Color(0xFF6FE3F5);
      final parpadeo =
          0.5 + 0.5 * math.sin((progreso * 6.28318 * 2) + p.fase * 6.28318);
      final paint = Paint()
        ..color = base.withValues(alpha: 0.12 + 0.3 * parpadeo)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.radio,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticulasPainter old) => old.progreso != progreso;
}

class _Punto {
  const _Punto({
    required this.x,
    required this.y,
    required this.radio,
    required this.velocidad,
    required this.fase,
    required this.azul,
  });

  final double x;
  final double y;
  final double radio;
  final double velocidad;
  final double fase;
  final bool azul;
}

/// Viñeta que oscurece los bordes para dar foco al centro.
class _Vineta extends StatelessWidget {
  const _Vineta();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 1.1,
          colors: [Colors.transparent, const Color(0xE604050A)],
          stops: const [0.5, 1.0],
        ),
      ),
    );
  }
}

/// Patrón de cuadrícula tenue.
class _PatronCuadricula extends CustomPainter {
  const _PatronCuadricula();

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = Colors.white.withValues(alpha: 0.018)
      ..strokeWidth = 1;
    const paso = 48.0;
    for (var x = 0.0; x < size.width; x += paso) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), pincel);
    }
    for (var y = 0.0; y < size.height; y += paso) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), pincel);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Marca gigante de fondo con degradado.
class _MarcaAgua extends StatelessWidget {
  const _MarcaAgua();

  @override
  Widget build(BuildContext context) {
    final dims = MediaQuery.sizeOf(context);
    final tamano = math.min(
      210.0,
      math.min(dims.width * 0.42, dims.height * 0.34),
    );
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x1A2E7BFF),
                Color(0x0D22D3EE),
                Color(0x00000000),
              ],
            ).createShader(rect),
            child: Text(
              'FITCORE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: tamano,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                height: 1.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Columna de marca que acompana al formulario en pantallas anchas.
class _ZonaMarca extends StatelessWidget {
  const _ZonaMarca();

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final escala = ancho >= 1300 ? 1.0 : 0.85;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _LogoFitCore(tamano: 56),
              const SizedBox(width: 14),
              Text(
                'FitCore',
                style: TextStyle(
                  fontSize: 30 * escala,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          SizedBox(height: 34 * escala),
          Text(
            'Todo tu gimnasio,\nen un solo panel.',
            style: TextStyle(
              fontSize: 52 * escala,
              fontWeight: FontWeight.w900,
              height: 1.06,
              letterSpacing: -1.4,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20 * escala),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Text(
              'Gestiona socios, instructores, clases, membresías, pagos y '
              'reportes en tiempo real, desde donde estés.',
              style: TextStyle(
                fontSize: 16 * escala,
                height: 1.55,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          SizedBox(height: 34 * escala),
          const _Beneficio(
            icono: Icons.shield_outlined,
            texto: 'Acceso por roles: administrador, instructor y cliente',
          ),
          SizedBox(height: 16 * escala),
          const _Beneficio(
            icono: Icons.bolt_outlined,
            texto: 'Membresías, pagos y avisos siempre al día',
          ),
          SizedBox(height: 16 * escala),
          const _Beneficio(
            icono: Icons.insights_outlined,
            texto: 'Reportes e indicadores en tiempo real',
          ),
        ],
      ),
    );
  }
}

/// Linea de beneficio con icono degradado.
class _Beneficio extends StatelessWidget {
  const _Beneficio({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [TemaFitCore.azul, TemaFitCore.cian],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: TemaFitCore.azul.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icono, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta glass con borde degradado.
class _TarjetaFormulario extends StatelessWidget {
  const _TarjetaFormulario({required this.child, this.padding = 32});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TemaFitCore.azul.withValues(alpha: 0.6),
            Colors.white.withValues(alpha: 0.06),
            TemaFitCore.cian.withValues(alpha: 0.4),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 60,
            offset: const Offset(0, 28),
          ),
          BoxShadow(
            color: TemaFitCore.azul.withValues(alpha: 0.12),
            blurRadius: 80,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            color: const Color(0xFF0D1422).withValues(alpha: 0.72),
            padding: EdgeInsets.all(padding),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Botón principal con destello que lo recorre.
class _BotonIngresar extends StatefulWidget {
  const _BotonIngresar({required this.cargando, required this.onTap});

  final bool cargando;
  final VoidCallback onTap;

  @override
  State<_BotonIngresar> createState() => _BotonIngresarState();
}

class _BotonIngresarState extends State<_BotonIngresar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _control;

  @override
  void initState() {
    super.initState();
    _control = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TemaFitCore.azul, TemaFitCore.cian],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: TemaFitCore.azul.withValues(alpha: 0.55),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SizedBox(
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _control,
                builder: (context, _) {
                  final t = _control.value;
                  return Align(
                    alignment: Alignment(-1.8 + t * 3.6, 0),
                    child: FractionallySizedBox(
                      widthFactor: 0.35,
                      heightFactor: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.35),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: widget.cargando ? null : widget.onTap,
                  child: Center(
                    child: widget.cargando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Envoltorio con animación de aparición suave.
class _EntradaAnimada extends StatelessWidget {
  const _EntradaAnimada({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, t, hijo) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 24),
            child: hijo,
          ),
        );
      },
      child: child,
    );
  }
}

/// Logo con degradado azul→cian y resplandor que respira.
class _LogoFitCore extends StatefulWidget {
  const _LogoFitCore({this.tamano = 44});

  final double tamano;

  @override
  State<_LogoFitCore> createState() => _LogoFitCoreState();
}

class _LogoFitCoreState extends State<_LogoFitCore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _control;

  @override
  void initState() {
    super.initState();
    _control = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tamano = widget.tamano;
    return AnimatedBuilder(
      animation: _control,
      builder: (context, _) {
        final t = _control.value;
        return Container(
          height: tamano,
          width: tamano,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [TemaFitCore.azul, TemaFitCore.cian],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(tamano * 0.3),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: TemaFitCore.azul.withValues(alpha: 0.4 + 0.35 * t),
                blurRadius: 22 + 20 * t,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: tamano * 0.48,
          ),
        );
      },
    );
  }
}
