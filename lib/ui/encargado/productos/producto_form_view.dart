import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../data/models/estacion.dart';
import '../../../data/models/producto.dart';
import '../../../data/repositories/foto_repository.dart';
import '../../../data/repositories/producto_repository.dart';
import '../../comun/foto_producto.dart';
import 'oferta_view.dart';
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
          actual: producto, fotos: ctx.read<FotoRepository>()),
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
  bool _inmediato = false;

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
      _inmediato = p.preparacionInmediata;
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
      preparacionInmediata: _inmediato,
    );
    if (ok && mounted) Navigator.pop(context, true);
  }

  /// La imagen se reduce a 1024 px y calidad 75 antes de enviarla.
  Future<void> _elegirFoto(ProductoFormViewModel vm, ImageSource origen) async {
    final picker = ImagePicker();
    final archivo = await picker.pickImage(
      source: origen,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 75,
    );
    if (archivo == null) return;
    final bytes = await archivo.readAsBytes();
    final tipo = archivo.name.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';
    await vm.subirFoto(bytes, tipo);
  }

  Future<void> _eliminar(ProductoFormViewModel vm) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar "${vm.actual!.nombre}"?'),
        content: const Text(
            'Dejará de aparecer en el menú. Los pedidos anteriores conservan su nombre y precio.'),
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
    if (ok != true) return;
    if (await vm.eliminar() && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoFormViewModel>();
    return Scaffold(
      appBar: AppBar(
          title: Text(vm.editando ? 'Editar producto' : 'Nuevo producto'),
          actions: [
            if (vm.editando)
              IconButton(
                tooltip: 'Eliminar producto',
                icon: const Icon(Icons.delete_outline),
                onPressed: vm.guardando ? null : () => _eliminar(vm),
              ),
          ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (vm.puedeTenerFoto) ...[
            Center(child: FotoProducto(url: vm.urlImagen, tamano: 120)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: vm.subiendoFoto
                      ? null
                      : () => _elegirFoto(vm, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galería'),
                ),
                if (ImagePicker().supportsImageSource(ImageSource.camera))
                  TextButton.icon(
                    onPressed: vm.subiendoFoto
                        ? null
                        : () => _elegirFoto(vm, ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Cámara'),
                  ),
              ],
            ),
            if (vm.subiendoFoto) const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ] else if (!vm.editando) ...[
            const Text(
                'Podrás agregar la foto después de guardar el producto.'),
            const SizedBox(height: 16),
          ],
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Preparación inmediata'),
            subtitle: const Text(
                'Se entrega al momento, como bebidas frías preempaquetadas.'),
            value: _inmediato,
            onChanged: (v) => setState(() => _inmediato = v),
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
          if (vm.editando) const OfertaSeccion(),
        ],
      ),
    );
  }
}
