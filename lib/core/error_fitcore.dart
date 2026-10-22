/// Error controlado con un mensaje listo para mostrar al usuario.
class ErrorFitCore implements Exception {
  ErrorFitCore(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
