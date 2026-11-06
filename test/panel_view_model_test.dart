import 'package:agilu/data/models/pedido_panel.dart';
import 'package:agilu/data/repositories/panel_repository.dart';
import 'package:agilu/ui/encargado/panel/panel_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

PedidoPanel _p(String id, int folio, EstadoPedido e, int minuto) => PedidoPanel(
      id: id,
      folio: folio,
      estado: e,
      recogerA: DateTime(2026, 11, 10, 12, minuto),
      alumno: 'A',
    );

Future<PanelViewModel> _vm(MockPanelRepository repo) async {
  final vm = PanelViewModel(repo);
  await Future<void>.delayed(Duration.zero);
  return vm;
}

void main() {
  test('agrupa por estado en orden de hora de recogida', () async {
    final vm = await _vm(MockPanelRepository(pedidos: [
      _p('a', 3, EstadoPedido.pendiente, 30),
      _p('b', 1, EstadoPedido.pendiente, 15),
      _p('c', 2, EstadoPedido.listo, 0),
    ]));
    expect(vm.enEstado(EstadoPedido.pendiente).map((p) => p.id), ['b', 'a']);
    expect(vm.enEstado(EstadoPedido.listo).single.id, 'c');
    expect(vm.enEstado(EstadoPedido.preparando), isEmpty);
  });

  test('avanza pendiente a preparando y luego a listo', () async {
    final repo =
        MockPanelRepository(pedidos: [_p('a', 1, EstadoPedido.pendiente, 0)]);
    final vm = await _vm(repo);
    await vm.avanzar(vm.enEstado(EstadoPedido.pendiente).single);
    expect(vm.enEstado(EstadoPedido.preparando).single.id, 'a');
    await vm.avanzar(vm.enEstado(EstadoPedido.preparando).single);
    expect(vm.enEstado(EstadoPedido.listo).single.id, 'a');
    expect(EstadoPedido.listo.siguiente, isNull);
  });

  test('si el pedido ya cambió en el servidor, avisa', () async {
    final repo =
        MockPanelRepository(pedidos: [_p('a', 1, EstadoPedido.preparando, 0)]);
    final vm = await _vm(repo);
    await vm.avanzar(_p('a', 1, EstadoPedido.pendiente, 0));
    expect(vm.error, 'El pedido ya cambió de estado. Se actualizó la lista.');
  });
}
