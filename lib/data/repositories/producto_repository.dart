import '../../dataconnect_generated/agilu.dart';
import '../models/producto.dart';

/// Catálogo que administra el encargado de una cafetería.
abstract class ProductoRepository {
  Future<List<Producto>> misProductos();
  Future<void> crear(DatosProducto datos);
  Future<void> editar(String id, DatosProducto datos);
  Future<void> establecerDisponibilidad(String id, bool disponible);
}

/// Lo que captura el encargado en el formulario de producto.
class DatosProducto {
  final String nombre;
  final String descripcion;
  final double precio;
  final String estacionId;
  final bool disponible;

  const DatosProducto({
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.estacionId,
    this.disponible = true,
  });
}

class DataConnectProductoRepository implements ProductoRepository {
  final AgiluConnector _conector;
  DataConnectProductoRepository({AgiluConnector? conector})
      : _conector = conector ?? AgiluConnector.instance;

  @override
  Future<List<Producto>> misProductos() async {
    final res = await _conector.misProductos().execute();
    return res.data.productos.map(aProducto).toList();
  }

  @override
  Future<void> crear(DatosProducto d) => _conector
      .crearMiProducto(
        nombre: d.nombre,
        precio: d.precio,
        puestoId: d.estacionId,
        disponible: d.disponible,
      )
      .descripcion(d.descripcion.isEmpty ? null : d.descripcion)
      .execute();

  @override
  Future<void> editar(String id, DatosProducto d) => _conector
      .editarMiProducto(
        id: id,
        nombre: d.nombre,
        precio: d.precio,
        puestoId: d.estacionId,
        disponible: d.disponible,
      )
      .descripcion(d.descripcion.isEmpty ? null : d.descripcion)
      .execute();

  @override
  Future<void> establecerDisponibilidad(String id, bool disponible) => _conector
      .establecerDisponibilidad(id: id, disponible: disponible)
      .execute();

  static Producto aProducto(MisProductosProductos p) => Producto(
        id: p.id,
        nombre: p.nombre,
        descripcion: p.descripcion ?? '',
        precio: p.precio,
        categoria: p.categoria,
        disponible: p.disponible,
        cafeteriaId: p.puesto.cafeteria.id,
        estacionId: p.puesto.id,
        estacion: p.puesto.nombre,
        estacionOrden: p.puesto.orden,
        urlImagen: p.urlDeImagen,
      );
}

class MockProductoRepository implements ProductoRepository {
  final List<Producto> productos = [
    const Producto(
        id: '1',
        nombre: 'Chilaquiles verdes',
        descripcion: 'Con pollo y crema',
        precio: 55,
        categoria: 'Desayunos',
        cafeteriaId: 'c1',
        estacionId: 'e2',
        estacion: 'Guisados',
        estacionOrden: 2),
    const Producto(
        id: '2',
        nombre: 'Molletes',
        descripcion: 'Con pico de gallo',
        precio: 40,
        categoria: 'Desayunos',
        cafeteriaId: 'c1',
        estacionId: 'e2',
        estacion: 'Guisados',
        estacionOrden: 2),
    const Producto(
        id: '3',
        nombre: 'Torta de milanesa',
        descripcion: 'Con aguacate',
        precio: 50,
        categoria: 'Comidas',
        cafeteriaId: 'c1',
        estacionId: 'e1',
        estacion: 'Tortas y hamburguesas',
        estacionOrden: 1),
    const Producto(
        id: '4',
        nombre: 'Hamburguesa sencilla',
        descripcion: 'Con papas',
        precio: 60,
        categoria: 'Comidas',
        cafeteriaId: 'c1',
        estacionId: 'e1',
        estacion: 'Tortas y hamburguesas',
        estacionOrden: 1),
    const Producto(
        id: '5',
        nombre: 'Agua de horchata',
        descripcion: '500 ml',
        precio: 20,
        categoria: 'Bebidas',
        cafeteriaId: 'c1',
        estacionId: 'e3',
        estacion: 'Tiendita',
        estacionOrden: 3),
    const Producto(
        id: '6',
        nombre: 'Café americano',
        descripcion: '12 oz',
        precio: 25,
        categoria: 'Bebidas',
        disponible: false,
        cafeteriaId: 'c1',
        estacionId: 'e3',
        estacion: 'Tiendita',
        estacionOrden: 3),
  ];

  int _siguiente = 7;

  @override
  Future<List<Producto>> misProductos() async => List.of(productos);

  @override
  Future<void> crear(DatosProducto d) async => productos.add(Producto(
        id: '${_siguiente++}',
        nombre: d.nombre,
        descripcion: d.descripcion,
        precio: d.precio,
        categoria: 'General',
        disponible: d.disponible,
        cafeteriaId: 'c1',
        estacionId: d.estacionId,
      ));

  @override
  Future<void> editar(String id, DatosProducto d) async {
    final i = productos.indexWhere((p) => p.id == id);
    final actual = productos[i];
    productos[i] = Producto(
      id: id,
      nombre: d.nombre,
      descripcion: d.descripcion,
      precio: d.precio,
      categoria: actual.categoria,
      disponible: d.disponible,
      cafeteriaId: actual.cafeteriaId,
      estacionId: d.estacionId,
      estacion: actual.estacionId == d.estacionId ? actual.estacion : '',
      estacionOrden: actual.estacionOrden,
    );
  }

  @override
  Future<void> establecerDisponibilidad(String id, bool disponible) async {
    final i = productos.indexWhere((p) => p.id == id);
    final p = productos[i];
    productos[i] = Producto(
      id: p.id,
      nombre: p.nombre,
      descripcion: p.descripcion,
      precio: p.precio,
      categoria: p.categoria,
      disponible: disponible,
      cafeteriaId: p.cafeteriaId,
      estacionId: p.estacionId,
      estacion: p.estacion,
      estacionOrden: p.estacionOrden,
      urlImagen: p.urlImagen,
    );
  }
}
