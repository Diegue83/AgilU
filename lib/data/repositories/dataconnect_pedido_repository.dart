import 'dart:math';

import 'package:firebase_data_connect/firebase_data_connect.dart';

import '../../core/reglas_pedido.dart';
import '../../dataconnect_generated/agilu.dart';
import '../models/pedido.dart';
import 'pedido_repository.dart';

/// Envía el pedido con la operación CrearPedido. El servidor toma los precios
/// del catálogo, calcula el total y asigna el folio; aquí solo se manda qué
/// productos y cuántos.
class DataConnectPedidoRepository implements PedidoRepository {
  final AgiluConnector _conector;
  final Random _azar;

  DataConnectPedidoRepository({AgiluConnector? conector, Random? azar})
      : _conector = conector ?? AgiluConnector.instance,
        _azar = azar ?? Random.secure();

  @override
  Future<String> crearPedido(Pedido pedido) async {
    final id = _uuidV4();
    final notas = pedido.notas.trim();
    final res = await _conector
        .crearPedido(
          id: id,
          puestoId: pedido.cafeteriaId,
          recogerA:
              Timestamp(0, pedido.recogerA.millisecondsSinceEpoch ~/ 1000),
          items: AnyValue(itemsDe(pedido)),
        )
        .notas(notas.isEmpty ? null : notas)
        .execute();

    if ((res.data.execute_ ?? 0) == 0) {
      throw Exception(
          'La cafetería rechazó el pedido. Revisa tu carrito e intenta de nuevo.');
    }

    final consulta = await _conector.miPedido(id: id).execute();
    return ReglasPedido.formatearFolio(consulta.data.pedidos.single.folio);
  }

  static List<Map<String, dynamic>> itemsDe(Pedido pedido) => [
        for (final i in pedido.items)
          {'productoId': i.producto.id, 'cantidad': i.cantidad},
      ];

  String _uuidV4() {
    final b = List<int>.generate(16, (_) => _azar.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }
}
