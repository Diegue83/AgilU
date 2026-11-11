import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/models/reporte.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/reporte_repository.dart';
import 'reporte_view_model.dart';

/// HU-11: cómo va el negocio, por cafetería.
class ReporteView extends StatelessWidget {
  const ReporteView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ReporteViewModel(ctx.read<ReporteRepository>()),
      child: const _Reporte(),
    );
  }
}

class _Reporte extends StatelessWidget {
  const _Reporte();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReporteViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthRepository>().cerrarSesion();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.login, (_) => false);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<Periodo>(
              segments: [
                for (final p in Periodo.values)
                  ButtonSegment(value: p, label: Text(p.etiqueta)),
              ],
              selected: {vm.periodo},
              onSelectionChanged: (s) => vm.elegir(s.first),
            ),
            const SizedBox(height: 16),
            if (vm.cargando) const LinearProgressIndicator(),
            if (vm.error != null) Text(vm.error!),
            if (!vm.cargando && vm.error == null) ...[
              _Tarjeta(fila: vm.total, destacada: true),
              for (final f in vm.filas) _Tarjeta(fila: f),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final FilaReporte fila;
  final bool destacada;
  const _Tarjeta({required this.fila, this.destacada = false});

  Widget _dato(BuildContext context, String etiqueta, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(etiqueta)),
            Text(valor, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final pct = (fila.tasaNoRecogidos * 100).toStringAsFixed(0);
    return Card(
      color: destacada ? Theme.of(context).colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fila.cafeteria,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _dato(context, 'Pedidos', '${fila.pedidos}'),
            _dato(context, 'Ingresos', '\$${fila.ingresos.toStringAsFixed(2)}'),
            _dato(context, 'Ticket promedio',
                '\$${fila.ticketPromedio.toStringAsFixed(2)}'),
            _dato(context, 'Entregados', '${fila.entregados}'),
            _dato(context, 'No recogidos', '${fila.noRecogidos} ($pct %)'),
            _dato(context, 'Monto no recogido',
                '\$${fila.montoNoRecogido.toStringAsFixed(2)}'),
            _dato(context, 'Cancelados', '${fila.cancelados}'),
          ],
        ),
      ),
    );
  }
}
