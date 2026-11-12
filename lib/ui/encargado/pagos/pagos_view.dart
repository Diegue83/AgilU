import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/reglas_pedido.dart';
import '../../../data/models/ticket.dart';
import '../../../data/repositories/pagos_repository.dart';
import 'pagos_view_model.dart';

/// HU-08: comprobantes de transferencia que esperan validación.
class PagosView extends StatelessWidget {
  const PagosView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PagosViewModel(ctx.read<PagosRepository>()),
      child: const _Pagos(),
    );
  }
}

class _Pagos extends StatelessWidget {
  const _Pagos();

  Future<void> _rechazar(
      BuildContext context, PagosViewModel vm, PagoPorValidar p) async {
    final ctrl = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rechazar pago de ${p.folio}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration:
              const InputDecoration(labelText: 'Motivo (lo verá el alumno)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Rechazar')),
        ],
      ),
    );
    if (motivo != null) await vm.rechazar(p, motivo);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PagosViewModel>();
    if (vm.cargando && vm.pagos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: vm.cargar,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (vm.error != null)
            MaterialBanner(
              content: Text(vm.error!),
              actions: const [SizedBox.shrink()],
            ),
          if (vm.pagos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No hay comprobantes por validar.'),
            ),
          for (final p in vm.pagos)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${p.folio} · ${p.alumno}',
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(
                        'Referencia ${p.referencia} · \$${p.total.toStringAsFixed(2)}'),
                    Text('Recoge ${ReglasPedido.formatearHora(p.recogerA)}'),
                    if (p.comprobanteUrl != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ImagenComprobante(ubicacion: p.comprobanteUrl!),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _rechazar(context, vm, p),
                            child: const Text('Rechazar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => vm.aprobar(p),
                            child: const Text('Aprobar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Comprobante guardado como URL (Cloud Functions) o como ruta en el bucket
/// privado de Supabase, que se descarga con la sesión del encargado.
class ImagenComprobante extends StatefulWidget {
  final String ubicacion;
  const ImagenComprobante({super.key, required this.ubicacion});

  @override
  State<ImagenComprobante> createState() => _ImagenComprobanteState();
}

class _ImagenComprobanteState extends State<ImagenComprobante> {
  late final Future<Uint8List>? _bytes = widget.ubicacion.startsWith('http')
      ? null
      : context.read<PagosRepository>().comprobante(widget.ubicacion);

  static const _error = Text('No se pudo mostrar el comprobante.');

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null) {
      return Image.network(widget.ubicacion,
          height: 220,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _error);
    }
    return FutureBuilder<Uint8List>(
      future: bytes,
      builder: (context, snap) {
        if (snap.hasError) return _error;
        if (!snap.hasData) {
          return const SizedBox(
              height: 220, child: Center(child: CircularProgressIndicator()));
        }
        return Image.memory(snap.data!,
            height: 220,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _error);
      },
    );
  }
}
