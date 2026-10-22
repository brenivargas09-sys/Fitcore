import '../modelos/aviso.dart';
import '../modelos/clase.dart';
import '../modelos/info_gimnasio.dart';
import '../modelos/membresia.dart';
import '../modelos/pago.dart';
import '../modelos/plan.dart';
import '../modelos/rutina.dart';
import '../modelos/usuario.dart';

/// Almacen en memoria que se usa cuando Supabase no esta configurado.
///
/// Permite probar el login y todo el panel administrativo sin backend.
class DemoDB {
  DemoDB._();
  static final DemoDB instancia = DemoDB._();

  final List<Usuario> usuarios = [];
  final Map<String, String> claves = {};
  final List<Clase> clases = [];
  final List<Rutina> rutinas = [];
  final List<Membresia> membresias = [];
  final List<Pago> pagos = [];
  final List<Aviso> avisos = [];
  final List<PlanMembresia> planes = [];
  InfoGimnasio? infoGimnasio;

  bool _sembrado = false;
  int _secuencia = 0;

  String nuevoId(String prefijo) => '$prefijo-${++_secuencia}';

  void sembrar() {
    if (_sembrado) return;
    _sembrado = true;

    _agregarUsuario(
      id: 'admin-1',
      nombre: 'Admin',
      apellidos: 'FitCore',
      correo: 'admin@fitcore.com',
      telefono: '600 000 001',
      rol: Rol.admin,
      clave: 'admin123',
    );
    _agregarUsuario(
      id: 'coach-1',
      nombre: 'Laura',
      apellidos: 'Méndez',
      correo: 'coach@fitcore.com',
      telefono: '600 000 002',
      rol: Rol.coach,
      clave: 'coach123',
      especialidad: 'Spinning',
    );
    _agregarUsuario(
      id: 'socio-1',
      nombre: 'Carlos',
      apellidos: 'Ruiz',
      correo: 'socio@fitcore.com',
      telefono: '600 000 003',
      rol: Rol.socio,
      clave: 'socio123',
    );
    _agregarUsuario(
      id: 'socio-2',
      nombre: 'María',
      apellidos: 'López',
      correo: 'maria@fitcore.com',
      telefono: '600 000 004',
      rol: Rol.socio,
      clave: 'socio123',
    );
    _agregarUsuario(
      id: 'socio-3',
      nombre: 'Javier',
      apellidos: 'Soto',
      correo: 'javier@fitcore.com',
      telefono: '600 000 005',
      rol: Rol.socio,
      clave: 'socio123',
      activo: false,
    );

    clases.addAll([
      const Clase(
        id: 'clase-1',
        nombre: 'Spinning',
        descripcion: 'Cardio intenso sobre bicicleta estática.',
        coachId: 'coach-1',
        coachNombre: 'Laura Méndez',
        diaSemana: 1,
        hora: '07:00',
        duracionMin: 45,
        cupoMax: 25,
        sala: 'Sala 1',
      ),
      const Clase(
        id: 'clase-2',
        nombre: 'Zumba',
        descripcion: 'Baile aeróbico para todos los niveles.',
        coachId: 'coach-1',
        coachNombre: 'Laura Méndez',
        diaSemana: 3,
        hora: '19:00',
        duracionMin: 60,
        cupoMax: 30,
        sala: 'Sala 2',
      ),
      const Clase(
        id: 'clase-3',
        nombre: 'Yoga',
        descripcion: 'Flexibilidad y respiración.',
        coachId: 'coach-1',
        coachNombre: 'Laura Méndez',
        diaSemana: 5,
        hora: '09:00',
        duracionMin: 60,
        cupoMax: 15,
        sala: 'Sala 2',
      ),
      const Clase(
        id: 'clase-4',
        nombre: 'Funcional',
        descripcion: 'Entrenamiento de fuerza y resistencia.',
        coachId: 'coach-1',
        coachNombre: 'Laura Méndez',
        diaSemana: 2,
        hora: '18:30',
        duracionMin: 50,
        cupoMax: 20,
        sala: 'Sala 1',
      ),
    ]);

    rutinas.addAll([
      const Rutina(
        id: 'rutina-1',
        nombre: 'Full Body Inicial',
        descripcion: 'Circuito de cuerpo completo en 8 estaciones.',
        coachId: 'coach-1',
        coachNombre: 'Laura Méndez',
        nivel: 'Principiante',
        semanas: 4,
      ),
      const Rutina(
        id: 'rutina-2',
        nombre: 'HIIT Quema',
        descripcion: 'Alta intensidad por intervalos.',
        coachId: 'coach-1',
        coachNombre: 'Laura Méndez',
        nivel: 'Avanzado',
        semanas: 6,
      ),
    ]);

    planes.addAll([
      const PlanMembresia(
        id: 'plan-1',
        nombre: 'Mensual',
        descripcion: 'Acceso completo por 30 días.',
        duracionDias: 30,
        precio: 39.90,
        condiciones: 'Renovación automática mensual.',
      ),
      const PlanMembresia(
        id: 'plan-2',
        nombre: 'Trimestral',
        descripcion: 'Acceso completo por 90 días.',
        duracionDias: 90,
        precio: 99.90,
        condiciones: 'Ahorro del 17% respecto al plan mensual.',
      ),
      const PlanMembresia(
        id: 'plan-3',
        nombre: 'Anual',
        descripcion: 'Acceso completo por 365 días.',
        duracionDias: 365,
        precio: 349.90,
        condiciones: 'Incluye 2 clases invítadas al mes.',
      ),
    ]);

    avisos.addAll([
      Aviso(
        id: 'aviso-1',
        titulo: 'Bienvenidos a Ciclic Studio',
        contenido:
            'FitCore ya está listo. Consulta las clases, rutinas y tu membresía desde la app.',
        fechaPublicacion:
            DateTime.now().subtract(const Duration(days: 2)),
        activo: true,
        importante: true,
      ),
      Aviso(
        id: 'aviso-2',
        titulo: 'Horario especial del sábado',
        contenido: 'El sábado la clase de Zumba es abierta para todos.',
        fechaPublicacion:
            DateTime.now().subtract(const Duration(days: 1)),
        activo: true,
        importante: false,
      ),
    ]);

    infoGimnasio = const InfoGimnasio(
      id: 'info-1',
      nombre: 'Ciclic Studio',
      descripcion:
          'Gimnasio especializado en clases de aeróbicos y entrenamiento funcional.',
      direccion: 'Calle Principal 123',
      telefono: '600 000 000',
      horariosAtencion:
          'Lunes a Viernes: 07:00 - 21:00\nSábados: 09:00 - 14:00',
      servicios: 'Spinning, Zumba, Yoga, Funcional',
    );

    final hoy = DateTime.now();
    for (final socio in usuarios.where((u) => u.rol == Rol.socio)) {
      membresias.add(
        Membresia(
          id: 'memb-${socio.id}',
          socioId: socio.id,
          socioNombre: socio.nombreCompleto,
          plan: 'Mensual',
          precio: 39.90,
          fechaInicio: hoy.subtract(const Duration(days: 10)),
          fechaFin: hoy.add(const Duration(days: 20)),
        ),
      );
      pagos.add(
        Pago(
          id: 'pago-${socio.id}',
          socioId: socio.id,
          socioNombre: socio.nombreCompleto,
          concepto: 'Mensualidad',
          monto: 39.90,
          metodo: 'Tarjeta',
          fecha: hoy.subtract(const Duration(days: 10)),
        ),
      );
    }
  }

  void _agregarUsuario({
    required String id,
    required String nombre,
    required String apellidos,
    required String correo,
    required String telefono,
    required Rol rol,
    required String clave,
    String? especialidad,
    bool activo = true,
  }) {
    usuarios.add(
      Usuario(
        id: id,
        nombre: nombre,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
        rol: rol,
        especialidad: especialidad,
        activo: activo,
        fechaRegistro: DateTime.now(),
      ),
    );
    claves[id] = clave;
  }
}
