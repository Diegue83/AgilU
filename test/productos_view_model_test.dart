import 'package:agilu/data/repositories/estacion_repository.dart';
import 'package:agilu/data/repositories/producto_repository.dart';
import 'package:agilu/ui/encargado/productos/productos_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProductosViewModel> _vm() async {
  final vm =
      ProductosViewModel(MockProductoRepository(), MockEstacionRepository());
  await vm.cargar();
  return vm;
}

void main() {
  test('muestra todos los productos ordenados por estación', () async {
    final vm = await _vm();
    expect(vm.visibles.first.estacion, 'Tortas y hamburguesas');
    expect(vm.visibles.last.estacion, 'Tiendita');
    expect(vm.visibles, hasLength(6));
  });

  test('filtra por estación', () async {
    final vm = await _vm();
    vm.seleccionarEstacion('e2');
    expect(
        vm.visibles.map((p) => p.nombre), ['Chilaquiles verdes', 'Molletes']);
  });

  test('busca por nombre sin importar mayúsculas ni acentos', () async {
    final vm = await _vm();
    vm.buscar('CAFE');
    expect(vm.visibles.single.nombre, 'Café americano');
  });

  test('combina búsqueda y estación', () async {
    final vm = await _vm();
    vm.seleccionarEstacion('e1');
    vm.buscar('torta');
    expect(vm.visibles.single.nombre, 'Torta de milanesa');
    vm.seleccionarEstacion('e3');
    expect(vm.visibles, isEmpty);
  });

  test('cada producto trae precio y disponibilidad', () async {
    final vm = await _vm();
    final cafe = vm.visibles.firstWhere((p) => p.nombre == 'Café americano');
    expect(cafe.precio, 25);
    expect(cafe.disponible, isFalse);
  });
}
