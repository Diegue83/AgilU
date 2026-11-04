import '../models/cafeteria.dart';
import '../models/producto.dart';

abstract class MenuRepository {
  Stream<List<Producto>> observarMenu();
  Future<List<Cafeteria>> cafeterias();
}

/// Datos de ejemplo para desarrollar sin Firebase.
class MockMenuRepository implements MenuRepository {
  final List<Cafeteria> lista;
  MockMenuRepository({
    this.lista = const [
      Cafeteria(
          id: 'cafeteria-central',
          nombre: 'Cafetería central',
          aperturaMinutos: 0,
          cierreMinutos: 24 * 60 - 1,
          anticipacionMinutos: 0),
    ],
  });

  @override
  Future<List<Cafeteria>> cafeterias() async => lista;

  @override
  Stream<List<Producto>> observarMenu() => Stream.value(const [
        Producto(
            id: '1',
            nombre: 'Chilaquiles verdes',
            descripcion: 'Con pollo y crema',
            precio: 55,
            categoria: 'Desayunos',
            estacionId: 'e2',
            estacion: 'Guisados',
            estacionOrden: 2),
        Producto(
            id: '2',
            nombre: 'Molletes',
            descripcion: 'Con pico de gallo',
            precio: 40,
            categoria: 'Desayunos',
            estacionId: 'e2',
            estacion: 'Guisados',
            estacionOrden: 2),
        Producto(
            id: '3',
            nombre: 'Torta de milanesa',
            descripcion: 'Con aguacate',
            precio: 50,
            categoria: 'Comidas',
            estacionId: 'e1',
            estacion: 'Tortas y hamburguesas',
            estacionOrden: 1),
        Producto(
            id: '4',
            nombre: 'Hamburguesa sencilla',
            descripcion: 'Con papas',
            precio: 60,
            categoria: 'Comidas',
            estacionId: 'e1',
            estacion: 'Tortas y hamburguesas',
            estacionOrden: 1),
        Producto(
            id: '5',
            nombre: 'Agua de horchata',
            descripcion: '500 ml',
            precio: 20,
            categoria: 'Bebidas',
            estacionId: 'e3',
            estacion: 'Tiendita',
            estacionOrden: 3),
        Producto(
            id: '6',
            nombre: 'Café americano',
            descripcion: '12 oz',
            precio: 25,
            categoria: 'Bebidas',
            disponible: false,
            estacionId: 'e3',
            estacion: 'Tiendita',
            estacionOrden: 3),
      ]);
}
