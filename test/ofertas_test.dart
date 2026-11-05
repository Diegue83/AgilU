import 'package:agilu/data/models/item_carrito.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/repositories/estacion_repository.dart';
import 'package:agilu/data/repositories/producto_repository.dart';
import 'package:agilu/ui/encargado/productos/producto_form_view_model.dart';
import 'package:agilu/ui/cart/cart_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

Producto _torta({double? oferta, DateTime? hasta, bool especialidad = false}) =>
    Producto(
      id: 't',
      nombre: 'Torta',
      descripcion: '',
      precio: 50,
      categoria: 'C',
      precioOferta: oferta,
      ofertaHasta: hasta,
      esEspecialidad: especialidad,
    );

void main() {
  final ahora = DateTime(2026, 11, 10, 12);

  test('la oferta vale hasta su fecha de término', () {
    final p = _torta(oferta: 35, hasta: DateTime(2026, 11, 10, 23, 59));
    expect(p.ofertaVigente(ahora), isTrue);
    expect(p.precioEn(ahora), 35);
    expect(p.precioEn(DateTime(2026, 11, 11)), 50);
    expect(p.destacadoEn(DateTime(2026, 11, 11)), isFalse);
  });

  test('una especialidad se destaca aunque no tenga precio promocional', () {
    final p = _torta(especialidad: true);
    expect(p.destacadoEn(ahora), isTrue);
    expect(p.precioEn(ahora), 50);
  });

  test('el carrito usa el precio promocional vigente', () {
    final futuro = DateTime.now().add(const Duration(days: 1));
    final carrito = CartViewModel();
    carrito.agregar(_torta(oferta: 35, hasta: futuro));
    carrito.agregar(_torta(oferta: 35, hasta: futuro));
    expect(carrito.total, 70);
    expect(
        ItemCarrito(producto: _torta(oferta: 35, hasta: futuro))
            .toMap()['precioUnitario'],
        35);
  });

  test('una oferta vencida no baja el total del carrito', () {
    final carrito = CartViewModel();
    carrito.agregar(_torta(
        oferta: 35,
        hasta: DateTime.now().subtract(const Duration(minutes: 1))));
    expect(carrito.total, 50);
  });

  group('formulario de oferta', () {
    late MockProductoRepository repo;
    late ProductoFormViewModel vm;
    setUp(() async {
      repo = MockProductoRepository();
      final estaciones = await MockEstacionRepository().misEstaciones();
      vm = ProductoFormViewModel(repo, estaciones,
          actual: repo.productos.firstWhere((p) => p.id == '3'));
    });

    test('valida precio, que sea menor al normal y fecha futura', () {
      expect(vm.validarOferta('0', ahora.add(const Duration(days: 1)), ahora),
          'Escribe un precio de oferta mayor a 0.');
      expect(vm.validarOferta('60', ahora.add(const Duration(days: 1)), ahora),
          'La oferta debe costar menos que el precio normal.');
      expect(vm.validarOferta('35', ahora, ahora),
          'Elige una fecha de término futura.');
      expect(vm.validarOferta('35', ahora.add(const Duration(days: 1)), ahora),
          isNull);
    });

    test('publica y quita la oferta', () async {
      final hasta = DateTime.now().add(const Duration(days: 2));
      expect(
          await vm.publicarOferta('35', hasta, true, DateTime.now()), isTrue);
      final p = repo.productos.firstWhere((p) => p.id == '3');
      expect(p.precioOferta, 35);
      expect(p.esEspecialidad, isTrue);
      expect(await vm.quitarOferta(), isTrue);
      expect(
          repo.productos.firstWhere((p) => p.id == '3').precioOferta, isNull);
    });
  });
}
