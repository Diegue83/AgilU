import 'package:agilu/data/models/pedido_panel.dart';
import 'package:agilu/data/models/ticket.dart';
import 'package:agilu/data/repositories/panel_repository.dart';
import 'package:agilu/ui/encargado/panel/panel_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

PedidoPanel _listo({int intentos = 0}) => PedidoPanel(
      id: 'p3',
      folio: 14,
      estado: EstadoPedido.listo,
      recogerA: DateTime(2026, 11, 10, 12),
      alumno: 'Carla',
      intentosEntrega: intentos,
    );

Future<PanelViewModel> _vm(MockPanelRepository repo) async {
  final vm = PanelViewModel(repo);
  await Future<void>.delayed(Duration.zero);
  return vm;
}

void main() {
  test('el encargado marca como no recogido un pedido listo y vencido',
      () async {
    final vencido = PedidoPanel(
      id: 'v1',
      folio: 20,
      estado: EstadoPedido.listo,
      recogerA: DateTime.now().subtract(const Duration(hours: 1)),
      alumno: 'Dani',
    );
    final aTiempo = PedidoPanel(
      id: 'v2',
      folio: 21,
      estado: EstadoPedido.listo,
      recogerA: DateTime.now().add(const Duration(hours: 1)),
      alumno: 'Eva',
    );
    final vm = await _vm(MockPanelRepository(pedidos: [vencido, aTiempo]));
    expect(await vm.marcarNoRecogido(aTiempo), isFalse);
    expect(vm.error, 'Solo se marca cuando ya pasó la hora de recogida.');
    expect(await vm.marcarNoRecogido(vencido), isTrue);
    expect(vm.enEstado(EstadoPedido.listo).single.id, 'v2');
    expect(EstadoPedido.desdeNombre('no_recogido'), EstadoPedido.noRecogido);
  });

  test('valida que el código tenga 4 dígitos antes de enviarlo', () async {
    final vm = await _vm(MockPanelRepository(pedidos: [_listo()]));
    expect(await vm.entregar(_listo(), '12'), isFalse);
    expect(vm.error, 'El código tiene 4 dígitos.');
  });

  test('con el código correcto el pedido sale del panel', () async {
    final vm = await _vm(MockPanelRepository(pedidos: [_listo()]));
    expect(await vm.entregar(_listo(), '4821'), isTrue);
    expect(vm.enEstado(EstadoPedido.listo), isEmpty);
    expect(vm.mensaje, 'Pedido AGU-00014 entregado.');
  });

  test('un código incorrecto no entrega y lo explica', () async {
    final vm = await _vm(MockPanelRepository(pedidos: [_listo()]));
    expect(await vm.entregar(_listo(), '1234'), isFalse);
    expect(vm.error, startsWith('Código incorrecto'));
  });

  test('con 5 intentos fallidos la entrega por código queda bloqueada',
      () async {
    expect(_listo(intentos: 5).entregaBloqueada, isTrue);
    final vm = await _vm(MockPanelRepository(pedidos: [_listo(intentos: 5)]));
    expect(await vm.entregar(_listo(intentos: 5), '4821'), isFalse);
    expect(vm.error, startsWith('Este pedido ya no se puede entregar'));
  });

  test('el ticket muestra el código solo mientras el pedido espera entregarse',
      () {
    TicketPedido t(EstadoPedido e) => TicketPedido(
        id: 'x',
        folio: 'AGU-1',
        referencia: 'AGU-1',
        estado: e,
        recogerA: DateTime(2026),
        total: 1,
        cafeteria: 'C',
        codigoEntrega: '4821');
    expect(t(EstadoPedido.listo).muestraCodigo, isTrue);
    expect(t(EstadoPedido.pendiente).muestraCodigo, isTrue);
    expect(t(EstadoPedido.entregado).muestraCodigo, isFalse);
    expect(t(EstadoPedido.porPagar).muestraCodigo, isFalse);
  });
}
