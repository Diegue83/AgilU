import '../../core/conector.dart';
import '../../dataconnect_generated/agilu.dart';

/// Cuántas cosas esperan al usuario con sesión; alimenta los puntos rojos.
class Contadores {
  /// Comprobantes por validar (encargado).
  final int pagos;

  /// Pedidos pagados que esperan cocina (encargado y empleado).
  final int enEspera;

  /// Solicitudes de trabajo (encargado).
  final int solicitudes;

  /// Pedidos propios listos para recoger (alumno).
  final int listos;

  /// Avisos sin leer.
  final int avisos;

  const Contadores({
    this.pagos = 0,
    this.enEspera = 0,
    this.solicitudes = 0,
    this.listos = 0,
    this.avisos = 0,
  });

  static const ceros = Contadores();

  factory Contadores.desdeMapa(Map m) {
    int n(String k) => (m[k] as num?)?.toInt() ?? 0;
    return Contadores(
      pagos: n('pagos'),
      enEspera: n('enEspera'),
      solicitudes: n('solicitudes'),
      listos: n('listos'),
      avisos: n('avisos'),
    );
  }
}

abstract class ContadoresRepository {
  Future<Contadores> misPendientes();
}

class DataConnectContadoresRepository implements ContadoresRepository {
  final AgiluConnector _conector;
  DataConnectContadoresRepository({AgiluConnector? conector})
      : _conector = conector ?? conectorAgilu;

  @override
  Future<Contadores> misPendientes() async {
    final res = await _conector.misPendientes().execute();
    return contadoresDe(res.data);
  }

  /// La respuesta de SQL nativo llega como AnyValue; el mapa está en .value.
  static Contadores contadoresDe(MisPendientesData d) {
    final fila = d.pendientes?.value;
    return fila is Map ? Contadores.desdeMapa(fila) : Contadores.ceros;
  }
}

class MockContadoresRepository implements ContadoresRepository {
  Contadores contadores;
  MockContadoresRepository({this.contadores = Contadores.ceros});

  @override
  Future<Contadores> misPendientes() async => contadores;
}
