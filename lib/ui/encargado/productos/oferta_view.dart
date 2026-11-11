import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/reglas_pedido.dart';
import 'producto_form_view_model.dart';

/// Sección del formulario para publicar o quitar una oferta (HU-21).
class OfertaSeccion extends StatefulWidget {
  const OfertaSeccion({super.key});

  @override
  State<OfertaSeccion> createState() => _OfertaSeccionState();
}

class _OfertaSeccionState extends State<OfertaSeccion> {
  final _precio = TextEditingController();
  DateTime? _hasta;
  bool _especialidad = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProductoFormViewModel>().actual;
    if (p != null && p.ofertaVigente(DateTime.now())) {
      _precio.text = p.precioOferta!.toStringAsFixed(2);
      _hasta = p.ofertaHasta;
    }
    _especialidad = p?.esEspecialidad ?? false;
  }

  @override
  void dispose() {
    _precio.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 90)),
      initialDate: _hasta ?? hoy,
      helpText: 'La oferta termina al final de este día',
    );
    if (dia != null) {
      setState(() => _hasta = DateTime(dia.year, dia.month, dia.day, 23, 59));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoFormViewModel>();
    final vigente = vm.actual?.ofertaVigente(DateTime.now()) ?? false;
    return Card(
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Oferta o especialidad',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _precio,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio promocional',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.event),
              label: Text(_hasta == null
                  ? 'Fecha de término'
                  : 'Termina el ${_hasta!.day}/${_hasta!.month} a las ${ReglasPedido.formatearHora(_hasta!)}'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Marcar como especialidad'),
              value: _especialidad,
              onChanged: (v) => setState(() => _especialidad = v),
            ),
            if (vm.errorOferta != null)
              Text(vm.errorOferta!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            Row(
              children: [
                if (vigente || (vm.actual?.esEspecialidad ?? false))
                  Expanded(
                      child: TextButton(
                    onPressed: vm.guardando
                        ? null
                        : () async {
                            if (await vm.quitarOferta() && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                    child: const Text('Quitar oferta'),
                  )),
                const SizedBox(width: 8),
                Expanded(
                    child: FilledButton.tonal(
                  onPressed: vm.guardando
                      ? null
                      : () async {
                          final ok = await vm.publicarOferta(_precio.text,
                              _hasta, _especialidad, DateTime.now());
                          if (ok && context.mounted) {
                            Navigator.pop(context, true);
                          }
                        },
                  child: const Text('Publicar oferta'),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
