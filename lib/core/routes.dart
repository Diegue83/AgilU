import '../data/models/perfil.dart';

class Routes {
  static const login = '/';
  static const menu = '/menu';
  static const carrito = '/carrito';
  static const confirmacion = '/confirmacion';
  static const encargado = '/encargado';

  /// Pantalla de inicio según el rol de quien inició sesión.
  static String inicioPara(Perfil? perfil) {
    if (perfil != null && perfil.esEncargado) return encargado;
    return menu;
  }
}
