import 'package:agilu/data/models/estacion.dart';
import 'package:agilu/data/repositories/producto_repository.dart';
import 'package:agilu/ui/encargado/productos/producto_form_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepoQueFalla extends MockProductoRepository {
  @override
  Future<void> crear(DatosProducto datos) async =>
      throw Exception('El precio debe ser mayor a 0');
}

const _estaciones = [
  Estacion(id: 'e1', nombre: 'Tortas'),
  Estacion(id: 'e2', nombre: 'Cerrada', activo: false),
];

void main() {
  test('solo ofrece estaciones activas', () {
    final vm = ProductoFormViewModel(MockProductoRepository(), _estaciones);
    expect(vm.estaciones.map((e) => e.id), ['e1']);
  });

  test('valida nombre, precio mayor a 0 y sección', () {
    final vm = ProductoFormViewModel(MockProductoRepository(), _estaciones);
    final e = vm.validar(' ', '0', null);
    expect(e.nombre, 'El nombre es obligatorio.');
    expect(e.precio, 'El precio debe ser mayor a 0.');
    expect(e.estacion, 'Elige una estación.');
    expect(vm.validar('Torta', 'abc', 'e1').precio, 'Escribe un precio válido.');
    expect(vm.validar('Torta', '45,50', 'e1').hayErrores, isFalse);
  });

  test('guarda con los datos limpios', () async {
    final repo = MockProductoRepository();
    final vm = ProductoFormViewModel(repo, _estaciones);
    final ok = await vm.guardar(
      nombre: '  Torta cubana ',
      descripcion: '',
      precio: '\$65',
      estacionId: 'e1',
      disponible: true,
    );
    expect(ok, isTrue);
    final p = repo.productos.last;
    expect(p.nombre, 'Torta cubana');
    expect(p.precio, 65);
    expect(p.estacionId, 'e1');
  });

  test('con errores no llama al repositorio', () async {
    final repo = MockProductoRepository();
    final antes = repo.productos.length;
    final vm = ProductoFormViewModel(repo, _estaciones);
    expect(
      await vm.guardar(
          nombre: '', descripcion: '', precio: '10', estacionId: 'e1', disponible: true),
      isFalse,
    );
    expect(repo.productos, hasLength(antes));
  });

  test('si el servidor rechaza, muestra su motivo', () async {
    final vm = ProductoFormViewModel(_RepoQueFalla(), _estaciones);
    final ok = await vm.guardar(
        nombre: 'Torta', descripcion: '', precio: '10', estacionId: 'e1', disponible: true);
    expect(ok, isFalse);
    expect(vm.error, 'El precio debe ser mayor a 0');
    expect(vm.guardando, isFalse);
  });
}
