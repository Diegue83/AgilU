import 'package:agilu/data/models/item_carrito.dart';
import 'package:agilu/data/models/pedido.dart';
import 'package:agilu/data/models/pedido_panel.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/models/ticket.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/ui/pedido/ticket_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _torta = Producto(
    id: 't', nombre: 'Torta', descripcion: '', precio: 50, categoria: 'C');

Future<String> _crear(MockPedidoRepository repo) async {
  final r = await repo.crearPedido(Pedido(
    usuarioId: 'u',
    cafeteriaId: 'c1',
    items: [ItemCarrito(producto: _torta)],
    total: 50,
    recogerA: DateTime(2026, 11, 12, 13),
  ));
  return r.id;
}

void _cambiarEstado(MockPedidoRepository repo, String id, EstadoPedido estado,
    {DateTime? pagadoEn}) {
  final t = repo.tickets[id]!;
  repo.tickets[id] = TicketPedido(
    id: t.id,
    folio: t.folio,
    referencia: t.referencia,
    estado: estado,
    recogerA: t.recogerA,
    total: t.total,
    cafeteria: t.cafeteria,
    pagadoEn: pagadoEn,
  );
}

void main() {
  test('se puede cancelar antes de que la cocina lo prepare', () {
    TicketPedido con(EstadoPedido e) => TicketPedido(
        id: '1',
        folio: 'AGU-00001',
        referencia: 'AGU-00001',
        estado: e,
        recogerA: DateTime(2026),
        total: 1,
        cafeteria: 'C');
    expect(con(EstadoPedido.porPagar).sePuedeCancelar, isTrue);
    expect(con(EstadoPedido.pagoEnRevision).sePuedeCancelar, isTrue);
    expect(con(EstadoPedido.pendiente).sePuedeCancelar, isTrue);
    expect(con(EstadoPedido.preparando).sePuedeCancelar, isFalse);
    expect(con(EstadoPedido.listo).sePuedeCancelar, isFalse);
    expect(con(EstadoPedido.entregado).sePuedeCancelar, isFalse);
  });

  test('cancelar un pedido sin pagar no pide reembolso', () async {
    final repo = MockPedidoRepository();
    final vm = TicketViewModel(repo, await _crear(repo));
    await vm.cargar();
    expect(await vm.cancelar(), isTrue);
    expect(vm.ticket!.estado, EstadoPedido.cancelado);
    expect(vm.estabaPagado, isFalse);
    expect(vm.ticket!.sePuedeCancelar, isFalse);
  });

  test('cancelar un pedido pagado avisa del reembolso', () async {
    final repo = MockPedidoRepository();
    final id = await _crear(repo);
    _cambiarEstado(repo, id, EstadoPedido.pendiente,
        pagadoEn: DateTime(2026, 11, 12, 11));
    final vm = TicketViewModel(repo, id);
    await vm.cargar();
    expect(await vm.cancelar(), isTrue);
    expect(vm.estabaPagado, isTrue);
  });

  test('en preparación ya no se cancela y se explica el motivo', () async {
    final repo = MockPedidoRepository();
    final id = await _crear(repo);
    final vm = TicketViewModel(repo, id);
    await vm.cargar();
    _cambiarEstado(repo, id, EstadoPedido.preparando);
    expect(await vm.cancelar(), isFalse);
    expect(vm.error, motivoNoCancelable);
    expect(vm.ticket!.estado, EstadoPedido.preparando);
  });
}
