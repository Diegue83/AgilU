import 'dart:async';

import 'package:firebase_data_connect/firebase_data_connect.dart';

import '../../dataconnect_generated/agilu.dart';
import '../models/pedido_panel.dart';

/// El estado del pedido cambió en el servidor antes que en la pantalla.
class PedidoDesactualizado implements Exception {
  @override
  String toString() => 'El pedido ya cambió de estado. Se actualizó la lista.';
}

abstract class PanelRepository {
  /// Pedidos de hoy de la cafetería del encargado; se actualiza solo.
  Stream<List<PedidoPanel>> observarHoy();
  Future<void> avanzar(PedidoPanel pedido);
}

class DataConnectPanelRepository implements PanelRepository {
  final AgiluConnector _conector;
  final Duration intervalo;
  final DateTime Function() _ahora;

  DataConnectPanelRepository({
    AgiluConnector? conector,
    this.intervalo = const Duration(seconds: 10),
    DateTime Function()? ahora,
  })  : _conector = conector ?? AgiluConnector.instance,
        _ahora = ahora ?? DateTime.now;

  static Timestamp _ts(DateTime t) =>
      Timestamp(0, t.millisecondsSinceEpoch ~/ 1000);

  Future<List<PedidoPanel>> _consultar() async {
    final ahora = _ahora();
    final desde = DateTime(ahora.year, ahora.month, ahora.day);
    final res = await _conector
        .panelPedidos(
            desde: _ts(desde), hasta: _ts(desde.add(const Duration(days: 1))))
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

  @override
  Stream<List<PedidoPanel>> observarHoy() {
    Timer? timer;
    late final StreamController<List<PedidoPanel>> controller;
    Future<void> refrescar() async {
      try {
        controller.add(await _consultar());
      } catch (e) {
        controller.addError(e);
      }
    }

    controller = StreamController<List<PedidoPanel>>(
      onListen: () {
        refrescar();
        timer = Timer.periodic(intervalo, (_) => refrescar());
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> avanzar(PedidoPanel pedido) async {
    final siguiente = pedido.estado.siguiente;
    if (siguiente == null) return;
    final res = await _conector
        .avanzarPedido(id: pedido.id, estado: siguiente.name)
        .execute();
    if ((res.data.execute_ ?? 0) == 0) throw PedidoDesactualizado();
  }
}

class MockPanelRepository implements PanelRepository {
  final _cambios = StreamController<List<PedidoPanel>>.broadcast();
  List<PedidoPanel> pedidos;

  MockPanelRepository({List<PedidoPanel>? pedidos})
      : pedidos = pedidos ??
            [
              PedidoPanel(
                id: 'p1',
                folio: 12,
                estado: EstadoPedido.pendiente,
                recogerA: DateTime.now().add(const Duration(minutes: 30)),
                alumno: 'Ana',
                notas: 'Sin cebolla',
                total: 80,
                lineas: const [LineaPanel(2, 'Molletes')],
              ),
              PedidoPanel(
                id: 'p2',
                folio: 13,
                estado: EstadoPedido.preparando,
                recogerA: DateTime.now().add(const Duration(minutes: 15)),
                alumno: 'Beto',
                total: 50,
                lineas: const [LineaPanel(1, 'Torta de milanesa')],
              ),
            ];

  @override
  Stream<List<PedidoPanel>> observarHoy() async* {
    yield List.of(pedidos);
    yield* _cambios.stream;
  }

  @override
  Future<void> avanzar(PedidoPanel pedido) async {
    final i = pedidos.indexWhere((p) => p.id == pedido.id);
    final siguiente = pedido.estado.siguiente;
    if (i < 0 || siguiente == null || pedidos[i].estado != pedido.estado) {
      throw PedidoDesactualizado();
    }
    pedidos[i] = pedidos[i].conEstado(siguiente);
    _cambios.add(List.of(pedidos));
  }
}
