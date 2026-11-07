import 'dart:typed_data';

import 'package:agilu/data/models/item_carrito.dart';
import 'package:agilu/data/models/pedido.dart';
import 'package:agilu/data/models/pedido_panel.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/repositories/pagos_repository.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/ui/encargado/pagos/pagos_view_model.dart';
import 'package:agilu/ui/pedido/ticket_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _torta = Producto(
    id: 't', nombre: 'Torta', descripcion: '', precio: 50, categoria: 'C');

Future<String> _crear(MockPedidoRepository repo) async {
  final r = await repo.crearPedido(Pedido(
    usuarioId: 'u',
    cafeteriaId: 'c1',
    items: [ItemCarrito(producto: _torta, cantidad: 2)],
    total: 100,
    recogerA: DateTime(2026, 11, 10, 13),
  ));
  return r.id;
}

void main() {
  test('el ticket recién creado espera comprobante y trae los datos de pago',
      () async {
    final repo = MockPedidoRepository();
    final vm = TicketViewModel(repo, await _crear(repo));
    await vm.cargar();
    final t = vm.ticket!;
    expect(t.estado, EstadoPedido.porPagar);
    expect(t.esperaComprobante, isTrue);
    expect(t.pagado, isFalse);
    expect(t.referencia, t.folio);
    expect(t.clabe, isNotNull);
    expect(t.lineas.single.subtotal, 100);
  });

  test('subir el comprobante deja el pedido en revisión', () async {
    final repo = MockPedidoRepository();
    final vm = TicketViewModel(repo, await _crear(repo));
    await vm.cargar();
    expect(
        await vm.subirComprobante(
            Uint8List.fromList([0xff, 0xd8, 0xff]), 'image/jpeg'),
        isTrue);
    expect(vm.ticket!.estado, EstadoPedido.pagoEnRevision);
    expect(await vm.subirComprobante(Uint8List(3), 'image/jpeg'), isFalse);
  });

  test('los estados de la base se leen con su clave', () {
    expect(EstadoPedido.desdeNombre('por_pagar'), EstadoPedido.porPagar);
    expect(EstadoPedido.desdeNombre('pago_en_revision'),
        EstadoPedido.pagoEnRevision);
    expect(EstadoPedido.pendiente.clave, 'pendiente');
  });

  group('validación de pagos', () {
    test('aprobar quita el pago de la lista', () async {
      final repo = MockPagosRepository();
      final vm = PagosViewModel(repo);
      await vm.cargar();
      expect(await vm.aprobar(vm.pagos.single), isTrue);
      expect(vm.pagos, isEmpty);
      expect(repo.resultados['p9'], isNull);
    });

    test('rechazar exige motivo', () async {
      final repo = MockPagosRepository();
      final vm = PagosViewModel(repo);
      await vm.cargar();
      expect(await vm.rechazar(vm.pagos.single, '  '), isFalse);
      expect(vm.error, 'Escribe el motivo del rechazo.');
      expect(await vm.rechazar(vm.pagos.single, 'Monto incompleto'), isTrue);
      expect(repo.resultados['p9'], 'Monto incompleto');
    });

    test('si otro dispositivo ya lo validó, avisa', () async {
      final repo = MockPagosRepository();
      final vm = PagosViewModel(repo);
      await vm.cargar();
      final p = vm.pagos.single;
      repo.pagos.clear();
      expect(await vm.aprobar(p), isFalse);
      expect(vm.error, 'Ese pago ya se había validado. Se actualizó la lista.');
    });
  });
}
