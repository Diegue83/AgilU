import '../models/producto.dart';

abstract class MenuRepository {
  Stream<List<Producto>> observarMenu();
}

/// Datos de ejemplo para desarrollar sin Firebase.
class MockMenuRepository implements MenuRepository {
  @override
  Stream<List<Producto>> observarMenu() => Stream.value(const [
        Producto(id: '1', nombre: 'Chilaquiles verdes', descripcion: 'Con pollo y crema', precio: 55, categoria: 'Desayunos'),
        Producto(id: '2', nombre: 'Molletes', descripcion: 'Con pico de gallo', precio: 40, categoria: 'Desayunos'),
        Producto(id: '3', nombre: 'Torta de milanesa', descripcion: 'Con aguacate', precio: 50, categoria: 'Comidas'),
        Producto(id: '4', nombre: 'Sopa del día', descripcion: 'Consulta en cafetería', precio: 35, categoria: 'Comidas'),
        Producto(id: '5', nombre: 'Agua de horchata', descripcion: '500 ml', precio: 20, categoria: 'Bebidas'),
        Producto(id: '6', nombre: 'Café americano', descripcion: '12 oz', precio: 25, categoria: 'Bebidas', disponible: false),
      ]);
}
