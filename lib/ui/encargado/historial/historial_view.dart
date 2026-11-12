import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/reglas_pedido.dart';
import '../../../data/models/pedido_panel.dart';
import '../../../data/repositories/historial_repository.dart';

enum PeriodoHistorial {
  hoy('Hoy', 0),
  semana('7 días', 6),
  mes('30 días', 29);

  final String etiqueta;
  final int diasAtras;
  const PeriodoHistorial(this.etiqueta, this.diasAtras);
}

/// Pedidos terminados de la cafetería con totales del periodo.
class HistorialViewModel extends ChangeNotifier {
  final HistorialRepository _repo;
  final DateTime Function() _ahora;
  HistorialViewModel(this._repo, {DateTime Function()? ahora})
      : _ahora = ahora ?? DateTime.now {
    cargar();
  }

  PeriodoHistorial periodo = PeriodoHistorial.hoy;
  List<PedidoPanel> pedidos = [];
  bool cargando = true;
  String? error;

  int _contar(EstadoPedido e) => pedidos.where((p) => p.estado == e).length;
  int get entregados => _contar(EstadoPedido.entregado);
  int get cancelados => _contar(EstadoPedido.cancelado);
  int get noRecogidos => _contar(EstadoPedido.noRecogido);
  double get vendido => pedidos
      .where((p) => p.estado == EstadoPedido.entregado)
      .fold(0, (s, p) => s + p.total);

  Future<void> elegir(PeriodoHistorial p) async {
    periodo = p;
    await cargar();
  }

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    final ahora = _ahora();
    final manana = DateTime(ahora.year, ahora.month, ahora.day + 1);
    final desde =
        DateTime(ahora.year, ahora.month, ahora.day - periodo.diasAtras);
    try {
      pedidos = await _repo.terminados(desde, manana);
      error = null;
    } catch (_) {
      error = 'No se pudo cargar el historial.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}

class HistorialView extends StatelessWidget {
  const HistorialView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => HistorialViewModel(ctx.read<HistorialRepository>()),
      child: const _Historial(),
    );
  }
}

class _Historial extends StatelessWidget {
  const _Historial();

  Widget _total(BuildContext context, String etiqueta, String valor) =>
      Expanded(
        child: Column(
          children: [
            Text(valor, style: Theme.of(context).textTheme.titleLarge),
            Text(etiqueta, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistorialViewModel>();
    String fecha(DateTime f) =>
        '${f.day}/${f.month} ${ReglasPedido.formatearHora(f)}';
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: RefreshIndicator(
        onRefresh: vm.cargar,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final p in PeriodoHistorial.values)
                    ChoiceChip(
                      label: Text(p.etiqueta),
                      selected: vm.periodo == p,
                      onSelected: (_) => vm.elegir(p),
                    ),
                ],
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    _total(context, 'Entregados', '${vm.entregados}'),
                    _total(context, 'Cancelados', '${vm.cancelados}'),
                    _total(context, 'No recogidos', '${vm.noRecogidos}'),
                    _total(context, 'Vendido',
                        '\$${vm.vendido.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
            if (vm.cargando) const LinearProgressIndicator(),
            if (vm.error != null)
              Padding(
                  padding: const EdgeInsets.all(16), child: Text(vm.error!)),
            if (!vm.cargando && vm.pedidos.isEmpty && vm.error == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No hay pedidos terminados en este periodo.'),
              ),
            for (final p in vm.pedidos)
              ListTile(
                title: Text(
                    '${ReglasPedido.formatearFolio(p.folio)} · ${p.alumno}'),
                subtitle: Text([
                  fecha(p.recogerA),
                  if (p.lineas.isNotEmpty)
                    p.lineas
                        .map((l) => '${l.cantidad} × ${l.producto}')
                        .join(', '),
                ].join('\n')),
                isThreeLine: p.lineas.isNotEmpty,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${p.total.toStringAsFixed(2)}'),
                    Text(p.estado.etiqueta,
                        style: TextStyle(
                            fontSize: 12,
                            color: p.estado == EstadoPedido.entregado
                                ? Colors.green.shade700
                                : Theme.of(context).colorScheme.error)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
