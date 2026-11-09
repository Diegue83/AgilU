/// Totales de una cafetería en un periodo (HU-11).
class FilaReporte {
  final String cafeteriaId;
  final String cafeteria;
  final int pedidos;
  final int entregados;
  final int noRecogidos;
  final int cancelados;
  final double ingresos;
  final double montoNoRecogido;

  const FilaReporte({
    required this.cafeteriaId,
    required this.cafeteria,
    this.pedidos = 0,
    this.entregados = 0,
    this.noRecogidos = 0,
    this.cancelados = 0,
    this.ingresos = 0,
    this.montoNoRecogido = 0,
  });

  /// Pedidos que llegaron a una entrega o a un no recogido.
  int get concluidos => entregados + noRecogidos;

  /// Porcentaje de pedidos concluidos que no se recogieron.
  double get tasaNoRecogidos => concluidos == 0 ? 0 : noRecogidos / concluidos;

  double get ticketPromedio => pedidos == 0 ? 0 : ingresos / pedidos;

  factory FilaReporte.desdeMapa(Map m) => FilaReporte(
        cafeteriaId: m['cafeteriaId'] as String,
        cafeteria: m['cafeteria'] as String,
        pedidos: (m['pedidos'] as num).toInt(),
        entregados: (m['entregados'] as num).toInt(),
        noRecogidos: (m['noRecogidos'] as num).toInt(),
        cancelados: (m['cancelados'] as num).toInt(),
        ingresos: (m['ingresos'] as num).toDouble(),
        montoNoRecogido: (m['montoNoRecogido'] as num).toDouble(),
      );

  static FilaReporte total(List<FilaReporte> filas) => FilaReporte(
        cafeteriaId: '',
        cafeteria: 'Total',
        pedidos: filas.fold(0, (s, f) => s + f.pedidos),
        entregados: filas.fold(0, (s, f) => s + f.entregados),
        noRecogidos: filas.fold(0, (s, f) => s + f.noRecogidos),
        cancelados: filas.fold(0, (s, f) => s + f.cancelados),
        ingresos: filas.fold(0.0, (s, f) => s + f.ingresos),
        montoNoRecogido: filas.fold(0.0, (s, f) => s + f.montoNoRecogido),
      );
}

enum Periodo {
  hoy('Hoy'),
  semana('Últimos 7 días'),
  mes('Últimos 30 días');

  final String etiqueta;
  const Periodo(this.etiqueta);

  /// Rango [desde, hasta) en hora local.
  (DateTime, DateTime) rango(DateTime ahora) {
    final manana = DateTime(ahora.year, ahora.month, ahora.day + 1);
    return switch (this) {
      Periodo.hoy => (DateTime(ahora.year, ahora.month, ahora.day), manana),
      Periodo.semana => (manana.subtract(const Duration(days: 7)), manana),
      Periodo.mes => (manana.subtract(const Duration(days: 30)), manana),
    };
  }
}
