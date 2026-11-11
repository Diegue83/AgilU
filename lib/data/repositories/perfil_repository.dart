import '../../core/conector.dart';
import '../../dataconnect_generated/agilu.dart';
import '../models/perfil.dart';

abstract class PerfilRepository {
  /// Crea el perfil del alumno con sesión si todavía no existe.
  Future<void> asegurarPerfil(String nombre);

  /// Perfil y rol del usuario con sesión, o null si aún no tiene perfil.
  Future<Perfil?> miPerfil();
}

class DataConnectPerfilRepository implements PerfilRepository {
  final AgiluConnector _conector;
  DataConnectPerfilRepository({AgiluConnector? conector})
      : _conector = conector ?? conectorAgilu;

  @override
  Future<void> asegurarPerfil(String nombre) async {
    final actual = await _conector.miPerfil().execute();
    if (actual.data.autenticacion != null) return;
    await _conector.crearPerfil(nombre: nombre).execute();
  }

  @override
  Future<Perfil?> miPerfil() async {
    final res = await _conector.miPerfil().execute();
    final a = res.data.autenticacion;
    return a == null ? null : aPerfil(a);
  }

  static Perfil aPerfil(MiPerfilAutenticacion a) => Perfil(
        nombre: a.usuario.nombre,
        correo: a.correoElectronico,
        rol: RolUsuario.desdeNombre(a.usuario.rol?.nombre),
        cafeteriaId: a.usuario.cafeteria?.id,
        cafeteria: a.usuario.cafeteria?.nombre,
      );
}

/// Perfil fijo para correr la app sin Firebase.
class MockPerfilRepository implements PerfilRepository {
  Perfil perfil;
  MockPerfilRepository({
    this.perfil =
        const Perfil(nombre: 'Alumno demo', correo: 'demo@utng.edu.mx'),
  });

  @override
  Future<void> asegurarPerfil(String nombre) async {}

  @override
  Future<Perfil?> miPerfil() async => perfil;
}
