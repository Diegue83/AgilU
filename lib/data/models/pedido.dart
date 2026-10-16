import 'item_carrito.dart';

class Pedido {
  final String usuarioId;
  final String cafeteriaId;
  final List<ItemCarrito> items;
  final double total;
  final DateTime recogerA;
  final String notas;
  final String estado;

  const Pedido({
    required this.usuarioId,
    required this.cafeteriaId,
    required this.items,
    required this.total,
    required this.recogerA,
    this.notas = '',
    this.estado = 'pendiente',
  });

  Map<String, dynamic> toMap() => {
        'usuarioId': usuarioId,
        'cafeteriaId': cafeteriaId,
        'items': items.map((e) => e.toMap()).toList(),
        'total': total,
        'estado': estado,
        if (notas.trim().isNotEmpty) 'notas': notas.trim(),
      };
}

class ResultadoPedido {
  final String folio;
  final DateTime recogerA;
  final double total;
  const ResultadoPedido(
      {required this.folio, required this.recogerA, required this.total});
}