import 'package:agilu/data/models/pedido_panel.dart';
import 'package:agilu/data/repositories/historial_repository.dart';
import 'package:agilu/ui/encargado/historial/historial_view.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _esperar() => Future<void>.delayed(Duration.zero);

class _Registro implements HistorialRepository {
  DateTime? desde;
  DateTime? hasta;
  @override
  Future<List<PedidoPanel>> terminados(DateTime desde, DateTime hasta) async {
    this.desde = desde;
    this.hasta = hasta;
    return const [];
  }
}

void main() {
  test('hoy trae solo los pedidos terminados de hoy con sus totales', () async {
    final vm = HistorialViewModel(MockHistorialRepository());
    await _esperar();
    expect(vm.pedidos.map((p) => p.folio), [7, 6]);
    expect(vm.entregados, 1);
    expect(vm.cancelados, 1);
    expect(vm.noRecogidos, 0);
    expect(vm.vendido, 95);
  });

  test('30 días incluye pedidos anteriores', () async {
    final vm = HistorialViewModel(MockHistorialRepository());
    await _esperar();
    await vm.elegir(PeriodoHistorial.mes);
    expect(vm.pedidos.map((p) => p.folio), contains(2));
    expect(vm.noRecogidos, 1);
  });

  test('los periodos piden el rango de días completo', () async {
    final repo = _Registro();
    final vm =
        HistorialViewModel(repo, ahora: () => DateTime(2026, 11, 12, 15, 30));
    await _esperar();
    expect(repo.desde, DateTime(2026, 11, 12));
    expect(repo.hasta, DateTime(2026, 11, 13));
    await vm.elegir(PeriodoHistorial.semana);
    expect(repo.desde, DateTime(2026, 11, 6));
  });
}
