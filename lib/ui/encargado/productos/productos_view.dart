import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/estacion_repository.dart';
import '../../../data/repositories/producto_repository.dart';
import '../../comun/foto_producto.dart';
import 'producto_form_view.dart';
import 'productos_view_model.dart';

class ProductosView extends StatelessWidget {
  const ProductosView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductosViewModel(
        ctx.read<ProductoRepository>(),
        ctx.read<EstacionRepository>(),
      ),
      child: const _Productos(),
    );
  }
}

class _Productos extends StatelessWidget {
  const _Productos();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductosViewModel>();
    if (vm.cargando && vm.total == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    final productos = vm.visibles;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: vm.estaciones.every((e) => !e.activo)
            ? null
            : () async {
                final guardado = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductoFormView(estaciones: vm.estaciones),
                  ),
                );
                if (guardado == true) await vm.cargar();
              },
        icon: const Icon(Icons.add),
        label: const Text('Producto'),
      ),
      body: RefreshIndicator(
        onRefresh: vm.cargar,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            if (vm.error != null)
              MaterialBanner(
                content: Text(vm.error!),
                actions: [
                  TextButton(
                      onPressed: vm.cargar, child: const Text('Reintentar')),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                onChanged: vm.buscar,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar por nombre',
                ),
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _chip('Todas', vm.estacionSeleccionada == null,
                      () => vm.seleccionarEstacion(null)),
                  for (final e in vm.estaciones)
                    _chip(e.nombre, vm.estacionSeleccionada == e.id,
                        () => vm.seleccionarEstacion(e.id)),
                ],
              ),
            ),
            if (productos.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(vm.total == 0
                    ? 'Aún no hay productos en tu cafetería.'
                    : 'Ningún producto coincide con la búsqueda.'),
              ),
            for (final p in productos)
              ListTile(
                onTap: () async {
                  final guardado = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductoFormView(
                          estaciones: vm.estaciones, producto: p),
                    ),
                  );
                  if (guardado == true) await vm.cargar();
                },
                leading: FotoProducto(url: p.urlImagen),
                title: Text(p.nombre),
                subtitle: Text(p.estacion),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${p.precio.toStringAsFixed(2)}'),
                        Text(
                          p.disponible ? 'Disponible' : 'Agotado',
                          style: TextStyle(
                            color: p.disponible
                                ? Colors.green.shade700
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: p.disponible,
                      onChanged: (_) => vm.alternarDisponible(p),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
