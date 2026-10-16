import 'app_config.dart';

class ReglasPedido {
  static List<DateTime> horasDisponibles(
    DateTime ahora, {
    int anticipacion = AppConfig.anticipacionMinutos,
    int intervalo = AppConfig.intervaloRecogidaMinutos,
    int apertura = AppConfig.aperturaMinutos,
    int cierre = AppConfig.cierreMinutos,
  }) {
    final inicioDia = DateTime(ahora.year, ahora.month, ahora.day);
    final minimo = ahora.add(Duration(minutes: anticipacion));
    final horas = <DateTime>[];
    for (var m = apertura; m <= cierre; m += intervalo) {
      final hora = inicioDia.add(Duration(minutes: m));
      if (!hora.isBefore(minimo)) horas.add(hora);
    }
    return horas;
  }

  static bool horaValida(DateTime elegida, DateTime ahora) =>
      horasDisponibles(ahora).any((h) => h.isAtSameMomentAs(elegida));

  static String formatearFolio(int n) => 'AGU-${n.toString().padLeft(5, '0')}';

  static String formatearHora(DateTime h) =>
      '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';
}