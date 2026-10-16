import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/menu_repository.dart';
import '../cart/cart_view_model.dart';
import 'menu_view_model.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => MenuViewModel(ctx.read<MenuRepository>()),
      child: const _MenuScaffold(),
    );
  }
}

class _MenuScaffold extends StatelessWidget {
  const _MenuScaffold();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MenuViewModel>();
    final carrito = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthRepository>().cerrarSesion();
              carrito.limpiar();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
          ),
        ],
      ),
      body: Builder(builder: (_) {
        if (vm.cargando) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.error != null) {
          return Center(child: Text(vm.error!));
        }
        return Column(
          children: [
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _chip('Todos', vm.categoriaSeleccionada == null,
                      () => vm.seleccionarCategoria(null)),
                  for (final c in vm.categorias)
                    _chip(c, vm.categoriaSeleccionada == c,
                        () => vm.seleccionarCategoria(c)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: vm.productosVisibles.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = vm.productosVisibles[i];
                  return ListTile(
                    title: Text(p.nombre),
                    subtitle: Text(
                        p.disponible ? p.descripcion : 'No disponible por ahora'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${p.precio.toStringAsFixed(2)}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: p.disponible
                              ? () {
                                  if (!carrito.agregar(p)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(carrito.error!)));
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: carrito.cantidadTotal == 0
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, Routes.carrito),
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                  'Carrito (${carrito.cantidadTotal}) · \$${carrito.total.toStringAsFixed(2)}'),
            ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );
}