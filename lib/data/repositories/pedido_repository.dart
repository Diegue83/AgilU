import '../../core/reglas_pedido.dart';
import '../models/pedido.dart';

/// El servidor no aceptó el pedido; [motivo] se muestra al alumno.
class PedidoRechazado implements Exception {
  final String motivo;
  const PedidoRechazado(this.motivo);

  @override
  String toString() => motivo;
}

abstract class PedidoRepository {
  /// Envía el pedido y devuelve el folio. Si el servidor lo rechaza, lanza
  /// una excepción con el motivo para el alumno.
  Future<String> crearPedido(Pedido pedido);

  /// Pedidos por hora de recogida de hoy en la cafetería.
  Future<Map<DateTime, int>> ocupacion(String cafeteriaId);
}

class MockPedidoRepository implements PedidoRepository {
  int _contador = 0;
  final Map<DateTime, int> ocupadas;
  MockPedidoRepository({Map<DateTime, int>? ocupadas})
      : ocupadas = ocupadas ?? {};

  @override
  Future<String> crearPedido(Pedido pedido) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _contador++;
    ocupadas.update(pedido.recogerA, (n) => n + 1, ifAbsent: () => 1);
    return ReglasPedido.formatearFolio(_contador);
  }

  @override
  Future<Map<DateTime, int>> ocupacion(String cafeteriaId) async =>
      Map.of(ocupadas);
}
