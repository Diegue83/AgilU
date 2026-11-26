import 'item_carrito.dart';

class Pedido {
  final String usuarioId;
  final String cafeteriaId;
  final List<ItemCarrito> items;
  final double total;
  final DateTime recogerA;
  final String notas;
  final String estado;

  /// Se paga en la cafetería al recoger (solo con 100 de confianza).
  final bool pagoAlRecoger;

  /// Pedidos del mismo carrito (uno por estación) comparten grupo.
  final String? grupo;

  const Pedido({
    required this.usuarioId,
    required this.cafeteriaId,
    required this.items,
    required this.total,
    required this.recogerA,
    this.notas = '',
    this.estado = 'pendiente',
    this.pagoAlRecoger = false,
    this.grupo,
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
  final String id;
  final String folio;
  final DateTime recogerA;
  final double total;

  /// Estación que cobra este pedido.
  final String estacion;

  /// Los demás pedidos del mismo carrito: cada estación cobra el suyo.
  final List<ResultadoPedido> otros;

  /// Qué estación no se pudo pedir y por qué (sus productos siguen en el carrito).
  final String? aviso;

  const ResultadoPedido(
      {this.id = '',
      required this.folio,
      required this.recogerA,
      required this.total,
      this.estacion = '',
      this.otros = const [],
      this.aviso});
}

/// Lo que regresa el servidor al registrar un pedido.
class PedidoCreado {
  final String id;
  final String folio;
  const PedidoCreado(this.id, this.folio);
}
