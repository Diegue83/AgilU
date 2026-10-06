import 'package:agilu/data/models/producto.dart';
import 'package:agilu/ui/cart/cart_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cafe = Producto(
      id: 'c1', nombre: 'Café', descripcion: '', precio: 25, categoria: 'Bebidas');

  test('agregar suma cantidades y total', () {
    final vm = CartViewModel();
    vm.agregar(cafe);
    vm.agregar(cafe);
    expect(vm.cantidadTotal, 2);
    expect(vm.total, 50);
  });

  test('quitarUno elimina el item al llegar a cero', () {
    final vm = CartViewModel();
    vm.agregar(cafe);
    vm.quitarUno('c1');
    expect(vm.vacio, isTrue);
  });
}
