import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/menu_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import '../cart/cart_view_model.dart';
import '../comun/foto_producto.dart';
import '../pedido/mis_pedidos_view.dart';
import 'menu_view_model.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => MenuViewModel(ctx.read<MenuRepository>(),
          pedidos: ctx.read<PedidoRepository>()),
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
        title: const Text('Menú de hoy'),
        actions: [
          IconButton(
            tooltip: 'Mis pedidos',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MisPedidosView())),
          ),
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
            if (vm.cafeterias.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: DropdownButtonFormField<String>(
                  initialValue: vm.cafeteriaSeleccionada,
                  decoration: const InputDecoration(labelText: 'Cafetería'),
                  items: [
                    for (final c in vm.cafeterias)
                      DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                  ],
                  onChanged: (id) {
                    if (id != null) vm.seleccionarCafeteria(id);
                  },
                ),
              ),
            if (vm.avisoConfianza != null)
              MaterialBanner(
                leading: const Icon(Icons.warning_amber),
                content: Text(vm.avisoConfianza!),
                actions: const [SizedBox.shrink()],
              ),
            if (vm.aviso != null)
              MaterialBanner(
                leading: const Icon(Icons.info_outline),
                content: Text(vm.aviso!),
                actions: const [SizedBox.shrink()],
              ),
            if (vm.destacados.isNotEmpty)
              SizedBox(
                height: 92,
                child: ListView(
                  key: const Key('destacados'),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  children: [
                    for (final p in vm.destacados)
                      Card(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  p.ofertaVigente(vm.ahora)
                                      ? 'Oferta'
                                      : 'Especialidad',
                                  style:
                                      Theme.of(context).textTheme.labelSmall),
                              Text(p.nombre,
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                              Text(
                                  '\$${p.precioEn(vm.ahora).toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    enabled: p.disponible,
                    leading: FotoProducto(url: p.urlImagen),
                    title: Text(p.nombre),
                    subtitle: Text(p.disponible
                        ? p.descripcion
                        : 'No disponible por ahora'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (p.ofertaVigente(vm.ahora))
                          Text('\$${p.precio.toStringAsFixed(2)} ',
                              style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey)),
                        Text('\$${p.precioEn(vm.ahora).toStringAsFixed(2)}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: p.disponible && vm.puedePedir
                              ? () {
                                  carrito.configurarCafeteria(vm.cafeteria);
                                  if (!carrito.agregar(p)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(carrito.error!)));
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
              onPressed: () {
                carrito.cargarOcupacion(context.read<PedidoRepository>());
                Navigator.pushNamed(context, Routes.carrito);
              },
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
