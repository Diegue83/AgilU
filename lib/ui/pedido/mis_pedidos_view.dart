import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/reglas_pedido.dart';
import '../../data/models/ticket.dart';
import '../../data/repositories/pedido_repository.dart';
import 'confirmacion_view.dart';

/// Pedidos del alumno con su estado; al tocar uno se abre su ticket.
class MisPedidosView extends StatefulWidget {
  const MisPedidosView({super.key});

  @override
  State<MisPedidosView> createState() => _MisPedidosViewState();
}

class _MisPedidosViewState extends State<MisPedidosView> {
  late Future<List<ResumenPedido>> _pedidos;

  @override
  void initState() {
    super.initState();
    _pedidos = context.read<PedidoRepository>().misPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: FutureBuilder<List<ResumenPedido>>(
        future: _pedidos,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(
                child: Text('No se pudieron cargar tus pedidos.'));
          }
          final lista = snap.data!;
          if (lista.isEmpty) {
            return const Center(child: Text('Aún no has hecho pedidos.'));
          }
          return ListView(
            children: [
              for (final p in lista)
                ListTile(
                  title: Text('${p.folio} · ${p.cafeteria}'),
                  subtitle: Text(
                      '${p.estado.etiqueta} · recoge ${ReglasPedido.formatearHora(p.recogerA)}'),
                  trailing: Text('\$${p.total.toStringAsFixed(2)}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TicketView(pedidoId: p.id)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
