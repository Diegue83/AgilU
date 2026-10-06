import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _auth;
  LoginViewModel(this._auth);

  bool cargando = false;
  bool modoRegistro = false;
  String? error;

  void alternarModo() {
    modoRegistro = !modoRegistro;
    error = null;
    notifyListeners();
  }

  /// Devuelve true si la autenticación fue exitosa.
  Future<bool> enviar(String correo, String contrasena) async {
    cargando = true;
    error = null;
    notifyListeners();
    try {
      if (modoRegistro) {
        await _auth.registrar(correo.trim(), contrasena);
      } else {
        await _auth.iniciarSesion(correo.trim(), contrasena);
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
