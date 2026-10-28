import '../../dataconnect_generated/agilu.dart';

abstract class PerfilRepository {
  /// Crea el perfil del alumno con sesión si todavía no existe.
  Future<void> asegurarPerfil(String nombre);
}

class DataConnectPerfilRepository implements PerfilRepository {
  final AgiluConnector _conector;
  DataConnectPerfilRepository({AgiluConnector? conector})
      : _conector = conector ?? AgiluConnector.instance;

  @override
  Future<void> asegurarPerfil(String nombre) async {
    final actual = await _conector.miPerfil().execute();
    if (actual.data.autenticacion != null) return;
    await _conector.crearPerfil(nombre: nombre).execute();
  }
}
