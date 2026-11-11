import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _auth;
  LoginViewModel(this._auth);

  static final _formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool cargando = false;
  bool modoRegistro = false;
  String? error;

  void alternarModo() {
    modoRegistro = !modoRegistro;
    error = null;
    notifyListeners();
  }

  /// Devuelve el problema con los datos capturados, o null si son válidos.
  String? validar(String correo, String contrasena) {
    if (correo.isEmpty || contrasena.isEmpty) {
      return 'Escribe tu correo y tu contraseña.';
    }
    if (!_formatoCorreo.hasMatch(correo)) {
      return 'El correo no tiene un formato válido.';
    }
    if (modoRegistro && contrasena.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  /// Devuelve true si la autenticación fue exitosa.
  Future<bool> enviar(String correo, String contrasena) async {
    if (cargando) return false;
    final limpio = correo.trim();
    final problema = validar(limpio, contrasena);
    if (problema != null) {
      error = problema;
      notifyListeners();
      return false;
    }

    cargando = true;
    error = null;
    notifyListeners();
    try {
      if (modoRegistro) {
        await _auth.registrar(limpio, contrasena);
      } else {
        await _auth.iniciarSesion(limpio, contrasena);
      }
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
