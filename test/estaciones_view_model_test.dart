import 'package:agilu/data/repositories/estacion_repository.dart';
import 'package:agilu/ui/encargado/estaciones/estaciones_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

Future<EstacionesViewModel> _vm() async {
  final vm = EstacionesViewModel(MockEstacionRepository());
  await vm.cargar();
  return vm;
}

void main() {
  test('carga las estaciones en orden', () async {
    final vm = await _vm();
    expect(vm.estaciones.map((e) => e.nombre),
        ['Tortas y hamburguesas', 'Guisados', 'Tiendita']);
  });

  test('valida nombre vacío o repetido', () async {
    final vm = await _vm();
    expect(vm.validarNombre('  '), 'Escribe el nombre de la estación.');
    expect(
        vm.validarNombre('tiendita'), 'Ya existe una estación con ese nombre.');
    expect(vm.validarNombre('Tiendita', exceptoId: 'e3'), isNull);
    expect(vm.validarNombre('Tacos'), isNull);
  });

  test('una estación nueva va al final', () async {
    final vm = await _vm();
    expect(await vm.crear('Tacos'), isTrue);
    expect(vm.estaciones.last.nombre, 'Tacos');
  });

  test('mover intercambia el orden con la vecina', () async {
    final vm = await _vm();
    await vm.mover(vm.estaciones[2], -1);
    expect(vm.estaciones.map((e) => e.nombre),
        ['Tortas y hamburguesas', 'Tiendita', 'Guisados']);
  });

  test('desactivar no borra la estación', () async {
    final vm = await _vm();
    await vm.alternarActiva(vm.estaciones.first);
    expect(vm.estaciones.first.activo, isFalse);
    expect(vm.estaciones, hasLength(3));
  });

  test('una estación con productos no se elimina y se explica por qué',
      () async {
    final vm = await _vm();
    expect(await vm.eliminar(vm.estaciones.first), isFalse);
    expect(vm.error,
        'La estación tiene productos: desactívala en lugar de borrarla');
    expect(vm.estaciones, hasLength(3));
  });

  test('una estación vacía sí se elimina', () async {
    final vm = await _vm();
    await vm.crear('Tacos');
    expect(await vm.eliminar(vm.estaciones.last), isTrue);
    expect(vm.estaciones, hasLength(3));
  });
}
