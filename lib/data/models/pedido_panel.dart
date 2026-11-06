/// Estados por los que pasa un pedido en la cafetería.
enum EstadoPedido {
  pendiente,
  preparando,
  listo,
  entregado,
  cancelado;

  static EstadoPedido desdeNombre(String nombre) =>
      EstadoPedido.values.firstWhere((e) => e.name == nombre,
          orElse: () => EstadoPedido.pendiente);

  /// Estado al que avanza desde el panel, o null si ya no avanza ahí.
  EstadoPedido? get siguiente => switch (this) {
        EstadoPedido.pendiente => EstadoPedido.preparando,
        EstadoPedido.preparando => EstadoPedido.listo,
        _ => null,
      };

  String get etiqueta => switch (this) {
        EstadoPedido.pendiente => 'En espera',
        EstadoPedido.preparando => 'Preparando',
        EstadoPedido.listo => 'Listo para entregar',
        EstadoPedido.entregado => 'Entregado',
        EstadoPedido.cancelado => 'Cancelado',
      };
}

class LineaPanel {
  final int cantidad;
  final String producto;
  const LineaPanel(this.cantidad, this.producto);
}

/// Pedido como lo ve el encargado en el panel operativo (HU-06).
class PedidoPanel {
  final String id;
  final int folio;
  final EstadoPedido estado;
  final DateTime recogerA;
  final String alumno;
  final String? notas;
  final double total;
  final List<LineaPanel> lineas;

  const PedidoPanel({
    required this.id,
    required this.folio,
    required this.estado,
    required this.recogerA,
    required this.alumno,
    this.notas,
    this.total = 0,
    this.lineas = const [],
  });

  PedidoPanel conEstado(EstadoPedido e) => PedidoPanel(
        id: id,
        folio: folio,
        estado: e,
        recogerA: recogerA,
        alumno: alumno,
        notas: notas,
        total: total,
        lineas: lineas,
      );
}
