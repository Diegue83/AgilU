import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/cafeteria.dart';
import '../../../data/repositories/cafeteria_repository.dart';
import 'cafeteria_view_model.dart';

/// Ajustes de horario y pedidos de la cafetería del encargado (HU-10).
class CafeteriaView extends StatelessWidget {
  const CafeteriaView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CafeteriaViewModel(ctx.read<CafeteriaRepository>()),
      child: const _Ajustes(),
    );
  }
}

class _Ajustes extends StatelessWidget {
  const _Ajustes();

  Future<int?> _hora(BuildContext context, int minutos) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutos ~/ 60, minute: minutos % 60),
    );
    return t == null ? null : t.hour * 60 + t.minute;
  }

  Widget _numero(String etiqueta, int valor, int min, int max, int paso,
          ValueChanged<int> cambio) =>
      ListTile(
        title: Text(etiqueta),
        subtitle: Text('$valor'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Menos',
              icon: const Icon(Icons.remove),
              onPressed: valor - paso < min ? null : () => cambio(valor - paso),
            ),
            IconButton(
              tooltip: 'Más',
              icon: const Icon(Icons.add),
              onPressed: valor + paso > max ? null : () => cambio(valor + paso),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CafeteriaViewModel>();
    final c = vm.cafeteria;
    if (vm.cargando && c == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c == null) return Center(child: Text(vm.error ?? ''));
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          title: Text(c.nombre, style: Theme.of(context).textTheme.titleMedium),
        ),
        ListTile(
          title: const Text('Abre'),
          subtitle: Text(Cafeteria.hora(c.aperturaMinutos)),
          trailing: const Icon(Icons.schedule),
          onTap: () async {
            final m = await _hora(context, c.aperturaMinutos);
            if (m != null) vm.cambiar(c.copiar(aperturaMinutos: m));
          },
        ),
        ListTile(
          title: const Text('Cierra'),
          subtitle: Text(Cafeteria.hora(c.cierreMinutos)),
          trailing: const Icon(Icons.schedule),
          onTap: () async {
            final m = await _hora(context, c.cierreMinutos);
            if (m != null) vm.cambiar(c.copiar(cierreMinutos: m));
          },
        ),
        _numero('Anticipación mínima (minutos)', c.anticipacionMinutos, 0, 240,
            15, (v) => vm.cambiar(c.copiar(anticipacionMinutos: v))),
        _numero(
            'Cada cuánto hay horario de recogida (minutos)',
            c.intervaloMinutos,
            5,
            60,
            5,
            (v) => vm.cambiar(c.copiar(intervaloMinutos: v))),
        _numero('Pedidos por horario', c.capacidadPorFranja, 1, 200, 1,
            (v) => vm.cambiar(c.copiar(capacidadPorFranja: v))),
        if (vm.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(vm.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        if (vm.mensaje != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(vm.mensaje!),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: vm.guardando ? null : vm.guardar,
            child: const Text('Guardar ajustes'),
          ),
        ),
      ],
    );
  }
}
