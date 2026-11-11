import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/estacion.dart';
import '../../../data/models/producto.dart';
import '../../../data/repositories/producto_repository.dart';
import 'producto_form_view_model.dart';

/// Formulario para dar de alta o editar un producto. Devuelve true al
/// cerrarse si se guardó.
class ProductoFormView extends StatelessWidget {
  final List<Estacion> estaciones;
  final Producto? producto;
  const ProductoFormView({super.key, required this.estaciones, this.producto});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductoFormViewModel(
          ctx.read<ProductoRepository>(), estaciones,
          actual: producto),
      child: const _Formulario(),
    );
  }
}

class _Formulario extends StatefulWidget {
  const _Formulario();

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  final _precio = TextEditingController();
  String? _estacionId;
  bool _disponible = true;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProductoFormViewModel>().actual;
    if (p != null) {
      _nombre.text = p.nombre;
      _descripcion.text = p.descripcion;
      _precio.text = p.precio.toStringAsFixed(2);
      _estacionId = p.estacionId;
      _disponible = p.disponible;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _precio.dispose();
    super.dispose();
  }

  Future<void> _guardar(ProductoFormViewModel vm) async {
    final ok = await vm.guardar(
      nombre: _nombre.text,
      descripcion: _descripcion.text,
      precio: _precio.text,
      estacionId: _estacionId,
      disponible: _disponible,
    );
    if (ok && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoFormViewModel>();
    return Scaffold(
      appBar: AppBar(
          title: Text(vm.editando ? 'Editar producto' : 'Nuevo producto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nombre,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Nombre',
              errorText: vm.errores.nombre,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descripcion,
            maxLines: 2,
            decoration:
                const InputDecoration(labelText: 'Descripción (opcional)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _precio,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Precio',
              prefixText: '\$ ',
              errorText: vm.errores.precio,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _estacionId,
            decoration: InputDecoration(
              labelText: 'Sección',
              errorText: vm.errores.estacion,
            ),
            items: [
              for (final e in vm.estaciones)
                DropdownMenuItem(value: e.id, child: Text(e.nombre)),
            ],
            onChanged: (v) => setState(() => _estacionId = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Disponible hoy'),
            value: _disponible,
            onChanged: (v) => setState(() => _disponible = v),
          ),
          if (vm.error != null) ...[
            const SizedBox(height: 8),
            Text(vm.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: vm.guardando ? null : () => _guardar(vm),
            child: vm.guardando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
