import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/codigo_qr.dart';
import '../../core/reglas_pedido.dart';
import '../../core/routes.dart';
import '../../data/models/pedido.dart';
import '../../data/models/pedido_panel.dart';
import '../../data/models/ticket.dart';
import '../../data/repositories/pedido_repository.dart';
import 'ticket_view_model.dart';

/// Pantalla que aparece al confirmar un pedido: muestra el ticket.
class ConfirmacionView extends StatelessWidget {
  final ResultadoPedido resultado;
  const ConfirmacionView({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) => TicketView(pedidoId: resultado.id);
}

/// HU-08 y HU-22: instrucciones de pago, carga del comprobante y recibo.
class TicketView extends StatelessWidget {
  final String pedidoId;
  const TicketView({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => TicketViewModel(ctx.read<PedidoRepository>(), pedidoId),
      child: const _Ticket(),
    );
  }
}

class _Ticket extends StatelessWidget {
  const _Ticket();

  Future<void> _subir(BuildContext context, TicketViewModel vm) async {
    final archivo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (archivo == null) return;
    final bytes = await archivo.readAsBytes();
    final tipo = archivo.name.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';
    await vm.subirComprobante(bytes, tipo);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketViewModel>();
    final t = vm.ticket;
    return Scaffold(
      appBar: AppBar(
        title: Text(t?.pagado ?? false ? 'Recibo' : 'Ticket de pago'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: vm.cargar,
          ),
        ],
      ),
      body: vm.cargando && t == null
          ? const Center(child: CircularProgressIndicator())
          : t == null
              ? Center(child: Text(vm.error ?? ''))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Chip(
                        avatar: Icon(t.pagado
                            ? Icons.check_circle
                            : Icons.hourglass_bottom),
                        label: Text(t.etiquetaEstado),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Folio', textAlign: TextAlign.center),
                    SelectableText(
                      t.folio,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Recoge hoy a las ${ReglasPedido.formatearHora(t.recogerA)} en ${t.cafeteria}'
                      '${t.ubicacion == null ? '' : ' (${t.ubicacion})'}',
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 32),
                    for (final l in t.lineas)
                      Row(
                        children: [
                          Expanded(
                              child: Text('${l.cantidad} × ${l.producto}')),
                          Text('\$${l.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                            child: Text('Total',
                                style:
                                    Theme.of(context).textTheme.titleMedium)),
                        Text('\$${t.total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    if (t.muestraCodigo) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              QrImageView(
                                key: const Key('qr-entrega'),
                                data: CodigoQr(t.id, t.codigoEntrega!).texto,
                                size: 180,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              const Text('Código de entrega'),
                              Text(
                                t.codigoEntrega!,
                                key: const Key('codigo-entrega'),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(letterSpacing: 8),
                              ),
                              const Text(
                                'Dicta o muestra este código en el mostrador para recoger tu pedido. '
                                'No lo compartas.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (t.pagadoEn != null)
                      Text(
                          'Pagado el ${t.pagadoEn!.day}/${t.pagadoEn!.month} a las ${ReglasPedido.formatearHora(t.pagadoEn!)}'),
                    if (t.esperaComprobante) ...[
                      const SizedBox(height: 16),
                      _Instrucciones(ticket: t),
                      if (t.motivoRechazo != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Tu comprobante anterior fue rechazado: ${t.motivoRechazo}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed:
                            vm.subiendo ? null : () => _subir(context, vm),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Subir comprobante'),
                      ),
                    ],
                    if (t.estado == EstadoPedido.pagoEnRevision) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Recibimos tu comprobante. La cafetería lo está revisando; '
                        'tu pedido entra a cocina en cuanto se valide.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (vm.subiendo) const LinearProgressIndicator(),
                    if (vm.error != null) ...[
                      const SizedBox(height: 8),
                      Text(vm.error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, Routes.menu),
                      child: const Text('Volver al menú'),
                    ),
                  ],
                ),
    );
  }
}

class _Instrucciones extends StatelessWidget {
  final TicketPedido ticket;
  const _Instrucciones({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cómo pagar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('1. Transfiere \$${ticket.total.toStringAsFixed(2)} a:'),
            if (ticket.banco != null) Text('Banco: ${ticket.banco}'),
            if (ticket.clabe != null) SelectableText('CLABE: ${ticket.clabe}'),
            if (ticket.titular != null) Text('Titular: ${ticket.titular}'),
            const SizedBox(height: 8),
            const Text('2. Escribe esta referencia como concepto:'),
            SelectableText(ticket.referencia,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('3. Sube aquí la captura o foto del comprobante.'),
          ],
        ),
      ),
    );
  }
}
