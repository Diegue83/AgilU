import 'package:firebase_data_connect/firebase_data_connect.dart';

import '../../core/conector.dart';
import '../../dataconnect_generated/agilu.dart';
import '../models/pedido_panel.dart';

/// Pedidos terminados de la cafetería del encargado o empleado con sesión.
abstract class HistorialRepository {
  Future<List<PedidoPanel>> terminados(DateTime desde, DateTime hasta);
}

class DataConnectHistorialRepository implements HistorialRepository {
  final AgiluConnector _conector;
  DataConnectHistorialRepository({AgiluConnector? conector})
      : _conector = conector ?? conectorAgilu;

  static Timestamp _ts(DateTime t) =>
      Timestamp(0, t.millisecondsSinceEpoch ~/ 1000);

  @override
  Future<List<PedidoPanel>> terminados(DateTime desde, DateTime hasta) async {
    final res = await _conector
        .historialPedidos(desde: _ts(desde), hasta: _ts(hasta))
        .execute();
    return res.data.pedidos
        .map((p) => PedidoPanel(
              id: p.id,
              folio: p.folio,
              estado: EstadoPedido.desdeNombre(p.estado),
              recogerA: p.recogerA.toDateTime().toLocal(),
              alumno: p.usuario.nombre,
              notas: p.notas,
              total: p.montoTotal,
              lineas: [
                for (final d in p.detallePedidos_on_pedido)
                  LineaPanel(d.cantidad, d.producto.nombre),
              ],
            ))
        .toList();
  }
}

class MockHistorialRepository implements HistorialRepository {
  final DateTime Function() _ahora;
  MockHistorialRepository({DateTime Function()? ahora})
      : _ahora = ahora ?? DateTime.now;

  List<PedidoPanel> get _todos {
    final ahora = _ahora();
    // Al inicio del día, para que "Hoy" no dependa de la hora de la prueba.
    final hoy = DateTime(ahora.year, ahora.month, ahora.day, 0, 10);
    return [
      PedidoPanel(
          id: 'h7',
          folio: 7,
          estado: EstadoPedido.entregado,
          recogerA: hoy.add(const Duration(minutes: 2)),
          alumno: 'Ana',
          total: 95,
          lineas: const [LineaPanel(2, 'Molletes')]),
      PedidoPanel(
          id: 'h6',
          folio: 6,
          estado: EstadoPedido.cancelado,
          recogerA: hoy,
          alumno: 'Beto',
          total: 40),
      PedidoPanel(
          id: 'h2',
          folio: 2,
          estado: EstadoPedido.noRecogido,
          recogerA: hoy.subtract(const Duration(days: 12)),
          alumno: 'Carla',
          total: 55),
    ];
  }

  @override
  Future<List<PedidoPanel>> terminados(DateTime desde, DateTime hasta) async =>
      _todos
          .where(
              (p) => !p.recogerA.isBefore(desde) && p.recogerA.isBefore(hasta))
          .toList();
}
