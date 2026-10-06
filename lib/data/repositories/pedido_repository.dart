import 'dart:math';

import '../models/pedido.dart';

abstract class PedidoRepository {
  /// Guarda el pedido y devuelve el folio.
  Future<String> crearPedido(Pedido pedido);
}

class MockPedidoRepository implements PedidoRepository {
  @override
  Future<String> crearPedido(Pedido pedido) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return 'AGU-${1000 + Random().nextInt(9000)}';
  }
}
