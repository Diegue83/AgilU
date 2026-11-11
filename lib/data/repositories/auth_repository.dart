abstract class AuthRepository {
  String? get uidActual;

  /// uid de la sesión que quedó abierta en el dispositivo, o null.
  Future<String?> sesionGuardada();
  Future<String> iniciarSesion(String correo, String contrasena);
  Future<String> registrar(String correo, String contrasena);
  Future<void> cerrarSesion();
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

  @override
  Future<String> registrar(String correo, String contrasena) =>
      _simular(correo, contrasena);

  @override
  Future<void> cerrarSesion() async => _uid = null;
}
