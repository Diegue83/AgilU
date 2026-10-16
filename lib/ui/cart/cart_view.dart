import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/reglas_pedido.dart';
import '../../core/routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import 'cart_view_model.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  Future<void> _confirmar(BuildContext context, CartViewModel vm) async {
    final problema = vm.validar();
    if (problema != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(problema)));
      return;
    }

    final acepta = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Confirmar pedido?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final i in vm.items)
              Text('${i.cantidad} × ${i.producto.nombre}'),
            const Divider(),
            Text('Total: \$${vm.total.toStringAsFixed(2)}'),
            Text('Recoges hoy a las ${ReglasPedido.formatearHora(vm.recogerA!)}'),
            const SizedBox(height: 8),
            const Text(
              'Una vez que el encargado empiece a prepararlo ya no podrás cancelarlo.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Revisar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Enviar pedido')),
        ],
      ),
    );
    if (acepta != true || !context.mounted) return;

    final nav = Navigator.of(context);
    final resultado = await vm.confirmar(
      context.read<AuthRepository>(),
      context.read<PedidoRepository>(),
    );
    if (resultado != null) {
      nav.pushReplacementNamed(Routes.confirmacion, arguments: resultado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CartViewModel>();
    final horas = vm.horasDisponibles;

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
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: horas.isEmpty
                            ? const Text(
                                'Ya no hay horarios disponibles para hoy. '
                                'Los pedidos se hacen con 1 hora de anticipación.')
                            : DropdownButtonFormField<DateTime>(
                                value: horas.contains(vm.recogerA)
                                    ? vm.recogerA
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: '¿A qué hora recoges? (hoy)',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  for (final h in horas)
                                    DropdownMenuItem(
                                      value: h,
                                      child: Text(ReglasPedido.formatearHora(h)),
                                    ),
                                ],
                                onChanged: vm.elegirHora,
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          maxLength: 200,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Notas para la cafetería (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: vm.escribirNotas,
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
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: vm.enviando || horas.isEmpty
                              ? null
                              : () => _confirmar(context, vm),
                          child: vm.enviando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Confirmar pedido'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}