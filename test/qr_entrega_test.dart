import 'package:agilu/core/codigo_qr.dart';
import 'package:agilu/data/models/pedido_panel.dart';
import 'package:agilu/data/repositories/panel_repository.dart';
import 'package:agilu/ui/encargado/panel/panel_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _id = 'b5f7e1c2-0d4a-4c3e-9a1b-2f6d8e9c0a11';

PedidoPanel _listo() => PedidoPanel(
      id: _id.replaceAll('-', ''),
      folio: 14,
      estado: EstadoPedido.listo,
      recogerA: DateTime(2026, 11, 10, 12),
      alumno: 'Carla',
    );

Future<PanelViewModel> _vm() async {
  final repo = MockPanelRepository(pedidos: [_listo()]);
  repo.codigos[_listo().id] = '4821';
  final vm = PanelViewModel(repo);
  await Future<void>.delayed(Duration.zero);
  return vm;
}

void main() {
  test('el QR lleva el pedido y su código y se puede leer de vuelta', () {
    final texto = const CodigoQr(_id, '4821').texto;
    final leido = CodigoQr.leer(texto)!;
    expect(leido.pedidoId, _id);
    expect(leido.codigo, '4821');
  });

  test('textos que no son QR de entrega se rechazan', () {
    expect(CodigoQr.leer('https://ejemplo.test'), isNull);
    expect(CodigoQr.leer('agilu-entrega:$_id:12'), isNull);
    expect(CodigoQr.leer("agilu-entrega:1' OR 1=1:4821"), isNull);
  });

  test('escanear el QR correcto entrega el pedido', () async {
    final vm = await _vm();
    expect(await vm.entregarConQr(const CodigoQr(_id, '4821').texto), isTrue);
    expect(vm.enEstado(EstadoPedido.listo), isEmpty);
  });

  test('un QR ya usado o de otro pedido se rechaza', () async {
    final vm = await _vm();
    await vm.entregarConQr(const CodigoQr(_id, '4821').texto);
    expect(await vm.entregarConQr(const CodigoQr(_id, '4821').texto), isFalse);
    expect(vm.error, contains('ya se usó'));
    const otro = 'c5f7e1c2-0d4a-4c3e-9a1b-2f6d8e9c0a11';
    expect(await vm.entregarConQr(const CodigoQr(otro, '4821').texto), isFalse);
  });

  test('un QR con el código equivocado no entrega', () async {
    final vm = await _vm();
    expect(await vm.entregarConQr(const CodigoQr(_id, '0000').texto), isFalse);
    expect(vm.error, startsWith('Código incorrecto'));
  });
}
