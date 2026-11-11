import '../../core/app_config.dart';

class Cafeteria {
  final String id;
  final String nombre;
  final int aperturaMinutos;
  final int cierreMinutos;
  final int anticipacionMinutos;
  final int intervaloMinutos;
  final bool activa;

  const Cafeteria({
    required this.id,
    required this.nombre,
    this.aperturaMinutos = AppConfig.aperturaMinutos,
    this.cierreMinutos = AppConfig.cierreMinutos,
    this.anticipacionMinutos = AppConfig.anticipacionMinutos,
    this.intervaloMinutos = AppConfig.intervaloRecogidaMinutos,
    this.activa = true,
  });

  static int _minutos(DateTime t) => t.hour * 60 + t.minute;

  /// Todavía se puede programar un pedido para hoy: queda al menos una hora de
  /// recogida que cumple la anticipación antes del cierre.
  bool recibePedidosHoy(DateTime ahora) =>
      activa && _minutos(ahora) + anticipacionMinutos <= cierreMinutos;

  bool abiertaAhora(DateTime ahora) =>
      activa &&
      _minutos(ahora) >= aperturaMinutos &&
      _minutos(ahora) <= cierreMinutos;

  static String hora(int minutos) =>
      '${(minutos ~/ 60).toString().padLeft(2, '0')}:${(minutos % 60).toString().padLeft(2, '0')}';
}
