/// Estados por los que pasa un pedido en la cafetería.
enum EstadoPedido {
  porPagar('por_pagar'),
  pagoEnRevision('pago_en_revision'),
  pendiente('pendiente'),
  preparando('preparando'),
  listo('listo'),
  entregado('entregado'),
  noRecogido('no_recogido'),
  cancelado('cancelado');

  /// Nombre del estado en la base de datos.
  final String clave;
  const EstadoPedido(this.clave);

  static EstadoPedido desdeNombre(String nombre) =>
      EstadoPedido.values.firstWhere((e) => e.clave == nombre,
          orElse: () => EstadoPedido.pendiente);

  /// Estado al que avanza desde el panel, o null si ya no avanza ahí.
  EstadoPedido? get siguiente => switch (this) {
        EstadoPedido.pendiente => EstadoPedido.preparando,
        EstadoPedido.preparando => EstadoPedido.listo,
        _ => null,
      };

  String get etiqueta => switch (this) {
        EstadoPedido.porPagar => 'Por pagar',
        EstadoPedido.pagoEnRevision => 'Pago en revisión',
        EstadoPedido.pendiente => 'En espera',
        EstadoPedido.preparando => 'Preparando',
        EstadoPedido.listo => 'Listo para entregar',
        EstadoPedido.entregado => 'Entregado',
        EstadoPedido.noRecogido => 'No recogido',
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
  final int intentosEntrega;
  final List<LineaPanel> lineas;

  /// Se cobra al entregar.
  final bool alRecoger;

  /// Cuándo hizo el pedido el alumno.
  final DateTime? creadoEn;

  const PedidoPanel({
    required this.id,
    required this.folio,
    required this.estado,
    required this.recogerA,
    required this.alumno,
    this.notas,
    this.total = 0,
    this.intentosEntrega = 0,
    this.lineas = const [],
    this.alRecoger = false,
    this.creadoEn,
  });

  /// "hace 5 min" o "hace 1 h 20 min" desde que se hizo el pedido.
  String? transcurrido(DateTime ahora) {
    final c = creadoEn;
    if (c == null) return null;
    final m = ahora.difference(c).inMinutes;
    if (m < 1) return 'hace menos de 1 min';
    if (m < 60) return 'hace $m min';
    final h = m ~/ 60;
    final r = m % 60;
    return r == 0 ? 'hace $h h' : 'hace $h h $r min';
  }

  /// HU-09: tras 5 códigos equivocados ya no se entrega con código.
  bool get entregaBloqueada => intentosEntrega >= 5;

  PedidoPanel conEstado(EstadoPedido e) => PedidoPanel(
        id: id,
        folio: folio,
        estado: e,
        recogerA: recogerA,
        alumno: alumno,
        notas: notas,
        total: total,
        intentosEntrega: intentosEntrega,
        lineas: lineas,
        alRecoger: alRecoger,
        creadoEn: creadoEn,
      );
}
