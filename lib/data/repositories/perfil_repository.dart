import '../../core/conector.dart';
import '../../dataconnect_generated/agilu.dart';
import '../models/perfil.dart';

abstract class PerfilRepository {
  /// Crea el perfil del alumno con sesión si todavía no existe. Todo perfil
  /// nuevo es de alumno.
  Future<void> asegurarPerfil(String nombre, {String? telefono});

  /// Perfil y rol del usuario con sesión, o null si aún no tiene perfil.
  Future<Perfil?> miPerfil();

  Future<void> editar(String nombre, String? telefono);

  /// Borra los datos personales del alumno con sesión. Si el servidor lo
  /// rechaza (pedidos en curso o cuenta del personal) lanza el motivo.
  Future<void> eliminarMiCuenta();
}

class DataConnectPerfilRepository implements PerfilRepository {
  final AgiluConnector _conector;
  DataConnectPerfilRepository({AgiluConnector? conector})
      : _conector = conector ?? conectorAgilu;

  @override
  Future<void> asegurarPerfil(String nombre, {String? telefono}) async {
    final actual = await _conector.miPerfil().execute();
    if (actual.data.autenticacion != null) return;
    var op = _conector.crearPerfil(nombre: nombre);
    if (telefono != null) op = op.telefono(telefono);
    await op.execute();
  }

  @override
  Future<Perfil?> miPerfil() async {
    final res = await _conector.miPerfil().execute();
    final a = res.data.autenticacion;
    return a == null ? null : aPerfil(a);
  }

  @override
  Future<void> editar(String nombre, String? telefono) =>
      _conector.editarMiPerfil(nombre: nombre).telefono(telefono).execute();

  static const motivosBaja = [
    'Tienes pedidos en curso: espera a recogerlos o cancélalos',
    'Las cuentas del personal no se eliminan desde la app',
  ];

  @override
  Future<void> eliminarMiCuenta() async {
    try {
      await _conector.eliminarMiCuenta().execute();
    } catch (e) {
      final texto = e.toString();
      throw Exception(motivosBaja.firstWhere(texto.contains,
          orElse: () => 'No se pudo eliminar la cuenta.'));
    }
  }

  static Perfil aPerfil(MiPerfilAutenticacion a) => Perfil(
        nombre: a.usuario.nombre,
        correo: a.correoElectronico,
        telefono: a.usuario.numeroDeTelefono,
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
  Future<void> asegurarPerfil(String nombre, {String? telefono}) async {}

  @override
  Future<Perfil?> miPerfil() async => perfil;

  /// Lo que respondería el servidor al pedir la baja.
  bool permitirBaja = true;
  bool eliminado = false;

  @override
  Future<void> editar(String nombre, String? telefono) async => perfil = Perfil(
        nombre: nombre,
        correo: perfil.correo,
        telefono: telefono,
        rol: perfil.rol,
        cafeteriaId: perfil.cafeteriaId,
        cafeteria: perfil.cafeteria,
      );

  @override
  Future<void> eliminarMiCuenta() async {
    if (!permitirBaja) {
      throw Exception(DataConnectPerfilRepository.motivosBaja.first);
    }
    eliminado = true;
  }
}
