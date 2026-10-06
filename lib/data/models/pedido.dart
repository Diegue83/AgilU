import 'item_carrito.dart';

class Pedido {
  final String usuarioId;
  final List<ItemCarrito> items;
  final double total;
  final String estado; // pendiente | preparando | listo | entregado
  final DateTime creadoEn;

  Pedido({
    required this.usuarioId,
    required this.items,
    required this.total,
    this.estado = 'pendiente',
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'usuarioId': usuarioId,
        'items': items.map((e) => e.toMap()).toList(),
        'total': total,
        'estado': estado,
        'creadoEn': creadoEn.toIso8601String(),
      };
}
