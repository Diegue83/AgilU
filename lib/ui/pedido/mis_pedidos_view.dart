import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/reglas_pedido.dart';
import '../../core/routes.dart';
import '../../data/models/ticket.dart';
import '../../data/repositories/menu_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import '../cart/cart_view_model.dart';
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

  /// Carga en el carrito lo de un pedido anterior que hoy sigue a la venta.
  Future<void> _volverAPedir(ResumenPedido p) async {
    final menu = context.read<MenuRepository>();
    final carrito = context.read<CartViewModel>();
    final mensajero = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      final productos = await menu.observarMenu().first;
      final cafeterias = await menu.cafeterias();
      carrito.configurarCafeteria(
          cafeterias.where((c) => c.id == p.cafeteriaId).firstOrNull);
      final faltan = carrito.volverAPedir(p.lineas, productos);
      if (carrito.vacio) {
        mensajero.showSnackBar(SnackBar(
            content: Text(carrito.error ??
                'Ninguno de esos productos está a la venta hoy.')));
        return;
      }
      if (faltan.isNotEmpty) {
        mensajero.showSnackBar(
            SnackBar(content: Text('No se agregó: ${faltan.join(', ')}.')));
      }
      nav.pushNamed(Routes.carrito);
    } catch (_) {
      mensajero.showSnackBar(const SnackBar(
          content: Text('No se pudo cargar el menú. Intenta de nuevo.')));
    }
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
                  trailing: p.sePuedeRepetir
                      ? TextButton.icon(
                          onPressed: () => _volverAPedir(p),
                          icon: const Icon(Icons.replay),
                          label: const Text('Volver a pedir'),
                        )
                      : Text('\$${p.total.toStringAsFixed(2)}'),
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
