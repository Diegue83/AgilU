import '../models/perfil.dart';

abstract class AuthRepository {
  String? get uidActual;

  /// uid de la sesión que quedó abierta en el dispositivo, o null.
  Future<String?> sesionGuardada();
  Future<String> iniciarSesion(String correo, String contrasena);

  /// Crea la cuenta y su perfil de alumno con los datos personales.
  Future<String> registrar(
      String correo, String contrasena, DatosPersonales datos);
  Future<void> cerrarSesion();

  /// Confirma la contraseña actual antes de una operación sensible.
  Future<void> reautenticar(String contrasena);

  Future<void> cambiarContrasena(String actual, String nueva);

  /// Borra la cuenta de inicio de sesión. Llamar después de [reautenticar].
  Future<void> eliminarCuentaActual();
}

/// Autenticación simulada: acepta cualquier correo con contraseña >= 6 caracteres.
class MockAuthRepository implements AuthRepository {
  String? _uid;

  @override
  String? get uidActual => _uid;

  @override
  Future<String?> sesionGuardada() async => _uid;

  Future<String> _simular(String correo, String contrasena) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!correo.contains('@') || contrasena.length < 6) {
      throw Exception('Correo o contraseña inválidos (mínimo 6 caracteres).');
    }
    _uid = 'usuario-demo';
    return _uid!;
  }

  @override
  Future<String> iniciarSesion(String correo, String contrasena) =>
      _simular(correo, contrasena);

  /// Datos del último registro, para revisar en pruebas.
  DatosPersonales? registrado;

  @override
  Future<String> registrar(
      String correo, String contrasena, DatosPersonales datos) {
    registrado = datos;
    return _simular(correo, contrasena);
  }

  @override
  Future<void> cerrarSesion() async => _uid = null;

  /// Contraseña de la cuenta simulada.
  String contrasena = '123456';
  bool eliminada = false;

  @override
  Future<void> reautenticar(String contrasena) async {
    if (contrasena != this.contrasena) {
      throw Exception('La contraseña actual no es correcta.');
    }
  }

  @override
  Future<void> cambiarContrasena(String actual, String nueva) async {
    await reautenticar(actual);
    contrasena = nueva;
  }

  @override
  Future<void> eliminarCuentaActual() async {
    eliminada = true;
    _uid = null;
  }
}
