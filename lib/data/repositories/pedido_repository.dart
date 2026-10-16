import '../../core/reglas_pedido.dart';
import '../models/pedido.dart';

abstract class PedidoRepository {
  Future<String> crearPedido(Pedido pedido);
}

class MockPedidoRepository implements PedidoRepository {
  int _contador = 0;

  @override
  Future<String> crearPedido(Pedido pedido) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _contador++;
    return ReglasPedido.formatearFolio(_contador);
  }
}