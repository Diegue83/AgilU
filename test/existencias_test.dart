import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/repositories/producto_repository.dart';
import 'package:agilu/ui/cart/cart_view_model.dart';
import 'package:agilu/ui/encargado/productos/producto_form_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

Producto _gelatina({int existencias = 2, bool controlar = true}) => Producto(
    id: 'g',
    nombre: 'Gelatina',
    descripcion: '',
    precio: 12,
    categoria: 'Postres',
    controlarStock: controlar,
    existencias: existencias);

void main() {
  test('la etiqueta dice disponible, últimas unidades o agotado', () {
    expect(_gelatina(existencias: 20).etiquetaExistencias, 'Disponible');
    expect(_gelatina(existencias: 5).etiquetaExistencias, 'Últimas 5');
    expect(_gelatina(existencias: 1).etiquetaExistencias, 'Última unidad');
    expect(_gelatina(existencias: 0).etiquetaExistencias, 'Agotado');
    expect(_gelatina(existencias: 0).disponibleAhora, isFalse);
    // Sin control de existencias manda la disponibilidad.
    final libre = _gelatina(existencias: 0, controlar: false);
    expect(libre.disponibleAhora, isTrue);
    expect(libre.etiquetaExistencias, 'Disponible');
  });

  test('el carrito no deja llevar más de lo que hay', () {
    final vm = CartViewModel();
    final g = _gelatina();
    expect(vm.agregar(g), isTrue);
    expect(vm.agregar(g), isTrue);
    expect(vm.agregar(g), isFalse);
    expect(vm.error, 'Solo quedan 2 de Gelatina.');
    expect(vm.items.single.cantidad, 2);
    expect(vm.agregar(_gelatina(existencias: 0)), isFalse);
  });

  test('el formulario valida las existencias solo si se controlan', () async {
    final repo = MockProductoRepository();
    final vm = ProductoFormViewModel(repo, const []);
    expect(
        vm
            .validar('Gelatina', '12', 'e1',
                controlarStock: true, existencias: '-1')
            .existencias,
        'Escribe un número de 0 a 9999.');
    expect(
        vm
            .validar('Gelatina', '12', 'e1',
                controlarStock: true, existencias: 'diez')
            .existencias,
        isNotNull);
    expect(
        vm
            .validar('Gelatina', '12', 'e1',
                controlarStock: false, existencias: 'diez')
            .existencias,
        isNull);
    expect(
        vm
            .validar('Gelatina', '12', 'e1',
                controlarStock: true, existencias: '8')
            .hayErrores,
        isFalse);
  });
}
