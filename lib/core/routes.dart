import '../data/models/perfil.dart';

class Routes {
  static const login = '/';
  static const registro = '/registro';
  static const registroEmpleado = '/registro-empleado';
  static const menu = '/menu';
  static const carrito = '/carrito';
  static const confirmacion = '/confirmacion';
  static const encargado = '/encargado';
  static const reporte = '/reporte';
  static const admin = '/admin';
  static const cuenta = '/cuenta';
  static const solicitud = '/solicitud';
  static const avisos = '/avisos';
  static const historial = '/historial';

  /// Pantalla de inicio según el rol de quien inició sesión.
  static String inicioPara(Perfil? perfil) {
    if (perfil != null && perfil.esAdmin) return admin;
    if (perfil != null && perfil.esPersonal) return encargado;
    if (perfil != null && perfil.esperandoAprobacion) return solicitud;
    if (perfil != null && perfil.esBeneficiaria) return reporte;
    return menu;
  }
}
