import '../../core/app_config.dart';

class Cafeteria {
  final String id;
  final String nombre;
  final int aperturaMinutos;
  final int cierreMinutos;
  final int anticipacionMinutos;
  final int intervaloMinutos;
  final int capacidadPorFranja;
  final bool activa;

  const Cafeteria({
    required this.id,
    required this.nombre,
    this.aperturaMinutos = AppConfig.aperturaMinutos,
    this.cierreMinutos = AppConfig.cierreMinutos,
    this.anticipacionMinutos = AppConfig.anticipacionMinutos,
    this.intervaloMinutos = AppConfig.intervaloRecogidaMinutos,
    this.capacidadPorFranja = 20,
    this.activa = true,
  });

  Cafeteria copiar({
    int? aperturaMinutos,
    int? cierreMinutos,
    int? anticipacionMinutos,
    int? intervaloMinutos,
    int? capacidadPorFranja,
  }) =>
      Cafeteria(
        id: id,
        nombre: nombre,
        aperturaMinutos: aperturaMinutos ?? this.aperturaMinutos,
        cierreMinutos: cierreMinutos ?? this.cierreMinutos,
        anticipacionMinutos: anticipacionMinutos ?? this.anticipacionMinutos,
        intervaloMinutos: intervaloMinutos ?? this.intervaloMinutos,
        capacidadPorFranja: capacidadPorFranja ?? this.capacidadPorFranja,
        activa: activa,
      );

  /// Devuelve el problema con los ajustes, o null si son válidos. Son las
  /// mismas reglas que valida EditarMiCafeteria en el servidor.
  String? validar() {
    if (aperturaMinutos < 0 ||
        cierreMinutos > 1439 ||
        aperturaMinutos >= cierreMinutos) {
      return 'La hora de cierre debe ser después de la apertura.';
    }
    if (anticipacionMinutos < 0 || anticipacionMinutos > 240) {
      return 'La anticipación debe estar entre 0 y 240 minutos.';
    }
    if (intervaloMinutos < 5 || intervaloMinutos > 60) {
      return 'El intervalo debe estar entre 5 y 60 minutos.';
    }
    if (capacidadPorFranja < 1 || capacidadPorFranja > 200) {
      return 'La capacidad debe estar entre 1 y 200 pedidos.';
    }
    return null;
  }

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
