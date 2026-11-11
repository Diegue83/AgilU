import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/estacion.dart';
import '../../../data/repositories/estacion_repository.dart';
import 'estaciones_view_model.dart';

class EstacionesView extends StatelessWidget {
  const EstacionesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => EstacionesViewModel(ctx.read<EstacionRepository>()),
      child: const _Estaciones(),
    );
  }
}

class _Estaciones extends StatelessWidget {
  const _Estaciones();

  Future<String?> _pedirNombre(BuildContext context, EstacionesViewModel vm,
      {Estacion? actual}) {
    final ctrl = TextEditingController(text: actual?.nombre ?? '');
    String? problema;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(actual == null ? 'Nueva estación' : 'Renombrar estación'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Nombre (ej. Tacos, Tiendita)',
              errorText: problema,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final p = vm.validarNombre(ctrl.text, exceptoId: actual?.id);
                if (p != null) {
                  setState(() => problema = p);
                } else {
                  Navigator.pop(ctx, ctrl.text);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(
      BuildContext context, EstacionesViewModel vm, Estacion e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar "${e.nombre}"?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) await vm.eliminar(e);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EstacionesViewModel>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final nombre = await _pedirNombre(context, vm);
          if (nombre != null) await vm.crear(nombre);
        },
        icon: const Icon(Icons.add),
        label: const Text('Estación'),
      ),
      body: vm.cargando && vm.estaciones.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
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
                  if (vm.estaciones.isEmpty && vm.error == null)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aún no hay estaciones. Agrega la primera.'),
                    ),
                  for (final (i, e) in vm.estaciones.indexed)
                    ListTile(
                      title: Text(e.nombre),
                      subtitle: Text(
                          '${e.productos} producto(s) · ${e.activo ? 'Visible' : 'Desactivada'}'),
                      leading: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: i == 0 ? null : () => vm.mover(e, -1),
                            child: const Icon(Icons.keyboard_arrow_up),
                          ),
                          InkWell(
                            onTap: i == vm.estaciones.length - 1
                                ? null
                                : () => vm.mover(e, 1),
                            child: const Icon(Icons.keyboard_arrow_down),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: e.activo,
                            onChanged: (_) => vm.alternarActiva(e),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (op) async {
                              if (op == 'renombrar') {
                                final n =
                                    await _pedirNombre(context, vm, actual: e);
                                if (n != null) await vm.renombrar(e, n);
                              } else if (context.mounted) {
                                await _confirmarEliminar(context, vm, e);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: 'renombrar', child: Text('Renombrar')),
                              PopupMenuItem(
                                value: 'eliminar',
                                enabled: e.sePuedeEliminar,
                                child: Text(e.sePuedeEliminar
                                    ? 'Eliminar'
                                    : 'Eliminar (tiene productos)'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
