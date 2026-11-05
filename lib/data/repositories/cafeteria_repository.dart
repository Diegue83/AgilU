import '../../dataconnect_generated/agilu.dart';
import '../models/cafeteria.dart';

/// Ajustes de la cafetería que administra el encargado (HU-10).
abstract class CafeteriaRepository {
  Future<Cafeteria?> miCafeteria();
  Future<void> guardar(Cafeteria c);
}

class DataConnectCafeteriaRepository implements CafeteriaRepository {
  final AgiluConnector _conector;
  DataConnectCafeteriaRepository({AgiluConnector? conector})
      : _conector = conector ?? AgiluConnector.instance;

  @override
  Future<Cafeteria?> miCafeteria() async {
    final res = await _conector.miCafeteria().execute();
    final c = res.data.autenticacion?.usuario.cafeteria;
    if (c == null) return null;
    return Cafeteria(
      id: c.id,
      nombre: c.nombre,
      aperturaMinutos: c.aperturaMinutos,
      cierreMinutos: c.cierreMinutos,
      anticipacionMinutos: c.anticipacionMinutos,
      intervaloMinutos: c.intervaloMinutos,
      capacidadPorFranja: c.capacidadPorFranja,
    );
  }

  @override
  Future<void> guardar(Cafeteria c) => _conector
      .editarMiCafeteria(
        aperturaMinutos: c.aperturaMinutos,
        cierreMinutos: c.cierreMinutos,
        anticipacionMinutos: c.anticipacionMinutos,
        intervaloMinutos: c.intervaloMinutos,
        capacidadPorFranja: c.capacidadPorFranja,
      )
      .execute();
}

class MockCafeteriaRepository implements CafeteriaRepository {
  Cafeteria cafeteria = const Cafeteria(id: 'c1', nombre: 'Cafetería central');

  @override
  Future<Cafeteria?> miCafeteria() async => cafeteria;

  @override
  Future<void> guardar(Cafeteria c) async => cafeteria = c;
}
