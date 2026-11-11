import '../../core/conector.dart';
import '../../dataconnect_generated/agilu.dart';
import '../models/estacion.dart';

abstract class EstacionRepository {
  /// Estaciones de la cafetería del encargado, en el orden del menú.
  Future<List<Estacion>> misEstaciones();
  Future<void> crear(String nombre, int orden);
  Future<void> editar(Estacion estacion);
  Future<void> eliminar(String id);
}

class DataConnectEstacionRepository implements EstacionRepository {
  final AgiluConnector _conector;
  DataConnectEstacionRepository({AgiluConnector? conector})
      : _conector = conector ?? conectorAgilu;

  @override
  Future<List<Estacion>> misEstaciones() async {
    final res = await _conector.misEstaciones().execute();
    return res.data.puestos
        .map((p) => Estacion(
              id: p.id,
              nombre: p.nombre,
              orden: p.orden,
              activo: p.activo,
              productos: p.productos_on_puesto.length,
            ))
        .toList();
  }

  @override
  Future<void> crear(String nombre, int orden) =>
      _conector.crearEstacion(nombre: nombre, orden: orden).execute();

  @override
  Future<void> editar(Estacion e) => _conector
      .editarEstacion(
          id: e.id, nombre: e.nombre, orden: e.orden, activo: e.activo)
      .execute();

  @override
  Future<void> eliminar(String id) =>
      _conector.eliminarEstacion(id: id).execute();
}

class MockEstacionRepository implements EstacionRepository {
  final List<Estacion> _estaciones = [
    const Estacion(
        id: 'e1', nombre: 'Tortas y hamburguesas', orden: 1, productos: 2),
    const Estacion(id: 'e2', nombre: 'Guisados', orden: 2, productos: 2),
    const Estacion(id: 'e3', nombre: 'Tiendita', orden: 3, productos: 2),
  ];
  int _siguiente = 4;

  @override
  Future<List<Estacion>> misEstaciones() async =>
      List.of(_estaciones)..sort((a, b) => a.orden.compareTo(b.orden));

  @override
  Future<void> crear(String nombre, int orden) async => _estaciones
      .add(Estacion(id: 'e${_siguiente++}', nombre: nombre, orden: orden));

  @override
  Future<void> editar(Estacion e) async {
    final i = _estaciones.indexWhere((x) => x.id == e.id);
    if (i >= 0) _estaciones[i] = e;
  }

  @override
  Future<void> eliminar(String id) async {
    final e = _estaciones.firstWhere((x) => x.id == id);
    if (!e.sePuedeEliminar) {
      throw Exception(
          'La estación tiene productos: desactívala en lugar de borrarla');
    }
    _estaciones.remove(e);
  }
}
