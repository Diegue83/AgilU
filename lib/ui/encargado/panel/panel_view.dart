import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/reglas_pedido.dart';
import '../../../data/models/pedido_panel.dart';
import '../../../data/repositories/panel_repository.dart';
import 'escaner_view.dart';
import 'panel_view_model.dart';

/// Panel operativo: pedidos de hoy por estado, en el orden en que se recogen.
class PanelView extends StatelessWidget {
  const PanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PanelViewModel(ctx.read<PanelRepository>()),
      child: const _Panel(),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel();

  static const _columnas = [
    EstadoPedido.pendiente,
    EstadoPedido.preparando,
    EstadoPedido.listo,
  ];

  /// El escáner usa la cámara del teléfono; en escritorio se entrega con PIN.
  static bool get _hayCamara =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PanelViewModel>();
    if (vm.cargando) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: _hayCamara
          ? FloatingActionButton.extended(
              onPressed: () async {
                final texto = await Navigator.push<String>(context,
                    MaterialPageRoute(builder: (_) => const EscanerView()));
                if (texto != null) await vm.entregarConQr(texto);
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear QR'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          if (vm.error != null)
            MaterialBanner(
              content: Text(vm.error!),
              actions: const [SizedBox.shrink()],
            ),
          if (vm.mensaje != null && vm.error == null)
            MaterialBanner(
              leading: const Icon(Icons.check_circle),
              content: Text(vm.mensaje!),
              actions: const [SizedBox.shrink()],
            ),
          for (final estado in _columnas) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                '${estado.etiqueta} (${vm.enEstado(estado).length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (vm.enEstado(estado).isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Sin pedidos.'),
              ),
            for (final p in vm.enEstado(estado)) _Tarjeta(pedido: p),
          ],
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final PedidoPanel pedido;
  const _Tarjeta({required this.pedido});

  Future<void> _entregar(BuildContext context, PanelViewModel vm) async {
    final ctrl = TextEditingController();
    final codigo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Entregar ${ReglasPedido.formatearFolio(pedido.folio)}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(labelText: 'Código del alumno'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Entregar')),
        ],
      ),
    );
    if (codigo != null) await vm.entregar(pedido, codigo);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<PanelViewModel>();
    final siguiente = pedido.estado.siguiente;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(ReglasPedido.formatearFolio(pedido.folio),
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text('Recoge ${ReglasPedido.formatearHora(pedido.recogerA)}'),
              ],
            ),
            Text(pedido.alumno),
            const SizedBox(height: 4),
            for (final l in pedido.lineas)
              Text('${l.cantidad} × ${l.producto}'),
            if (pedido.notas != null && pedido.notas!.isNotEmpty)
              Text('Nota: ${pedido.notas}',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
            if (pedido.estado == EstadoPedido.listo &&
                pedido.recogerA.isBefore(DateTime.now())) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => vm.marcarNoRecogido(pedido),
                  child: const Text('No se presentó'),
                ),
              ),
            ],
            if (pedido.estado == EstadoPedido.listo) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: pedido.entregaBloqueada
                      ? null
                      : () => _entregar(context, vm),
                  child: Text(pedido.entregaBloqueada
                      ? 'Bloqueado por intentos'
                      : 'Entregar con código'),
                ),
              ),
            ],
            if (siguiente != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: context.watch<PanelViewModel>().avanzando(pedido)
                      ? null
                      : () => vm.avanzar(pedido),
                  child: Text(siguiente == EstadoPedido.preparando
                      ? 'Empezar a preparar'
                      : 'Marcar como listo'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
