import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import 'cart_view_model.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi carrito')),
      body: vm.vacio
          ? const Center(child: Text('Tu carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      for (final item in vm.items)
                        ListTile(
                          title: Text(item.producto.nombre),
                          subtitle: Text(
                              '\$${item.producto.precio.toStringAsFixed(2)} c/u'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => vm.quitarUno(item.producto.id),
                              ),
                              Text('${item.cantidad}'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => vm.agregar(item.producto),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => vm.eliminar(item.producto.id),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total',
                              style: Theme.of(context).textTheme.titleLarge),
                          Text('\$${vm.total.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      if (vm.error != null) ...[
                        const SizedBox(height: 8),
                        Text(vm.error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      ],
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: vm.enviando
                            ? null
                            : () async {
                                final nav = Navigator.of(context);
                                final folio = await vm.confirmar(
                                  context.read<AuthRepository>(),
                                  context.read<PedidoRepository>(),
                                );
                                if (folio != null) {
                                  nav.pushReplacementNamed(Routes.confirmacion,
                                      arguments: folio);
                                }
                              },
                        child: vm.enviando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Confirmar pedido'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
