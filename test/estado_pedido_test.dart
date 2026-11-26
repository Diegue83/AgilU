import 'package:agilu/data/models/pedido_panel.dart';
import 'package:agilu/data/models/ticket.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/ui/pedido/confirmacion_view.dart';
import 'package:agilu/ui/pedido/ticket_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TicketPedido _t(EstadoPedido e) => TicketPedido(
      id: 'p1',
      folio: 'AGU-00001',
      referencia: 'AGU-00001',
      estado: e,
      recogerA: DateTime(2026, 11, 26, 12),
      total: 50,
      cafeteria: 'Central',
    );

void main() {
  test('cada estado cae en su paso y los finales no tienen paso', () {
    expect(_t(EstadoPedido.porPagar).pasoActual, 0);
    expect(_t(EstadoPedido.pagoEnRevision).pasoActual, 0);
    expect(_t(EstadoPedido.pendiente).pasoActual, 1);
    expect(_t(EstadoPedido.preparando).pasoActual, 2);
    expect(_t(EstadoPedido.listo).pasoActual, 3);
    expect(_t(EstadoPedido.entregado).pasoActual, 4);
    expect(_t(EstadoPedido.cancelado).pasoActual, isNull);
    expect(_t(EstadoPedido.entregado).terminado, isTrue);
    expect(_t(EstadoPedido.listo).terminado, isFalse);
  });

  test('el ticket se actualiza solo mientras el pedido avanza', () async {
    final repo = MockPedidoRepository()
      ..tickets['p1'] = _t(EstadoPedido.pendiente);
    final vm = TicketViewModel(repo, 'p1',
        intervalo: const Duration(milliseconds: 20));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(vm.ticket!.estado, EstadoPedido.pendiente);

    repo.tickets['p1'] = _t(EstadoPedido.listo);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(vm.ticket!.estado, EstadoPedido.listo);

    repo.tickets['p1'] = _t(EstadoPedido.entregado);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(vm.ticket!.estado, EstadoPedido.entregado);

    // Ya entregado deja de consultar.
    repo.tickets['p1'] = _t(EstadoPedido.cancelado);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(vm.ticket!.estado, EstadoPedido.entregado);
    vm.dispose();
  });

  testWidgets('el paso a paso resalta el paso en curso', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home:
            Scaffold(body: PasosPedido(paso: 2, etiquetaPago: 'Al recoger'))));
    expect(find.text('Al recoger'), findsOneWidget);
    expect(find.text('Preparando'), findsOneWidget);
    final enCurso = tester.widget<Text>(find.byKey(const Key('paso-2')));
    expect(enCurso.style!.fontWeight, FontWeight.bold);
    expect(find.byIcon(Icons.check), findsNWidgets(2));
  });
}
