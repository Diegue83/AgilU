import 'package:flutter/foundation.dart';

import '../../core/app_config.dart';
import '../../data/models/perfil.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import '../../data/repositories/perfil_repository.dart';
import '../auth/registro_view_model.dart';

/// Nivel de confianza del alumno según sus pedidos sin recoger (HU-23).
enum NivelConfianza {
  excelente('Excelente', 'No tienes pedidos sin recoger.'),
  buena('Buena', 'Tienes un pedido sin recoger en los últimos 30 días.'),
  enRiesgo('En riesgo',
      'Un pedido más sin recoger y no podrás hacer pedidos por un tiempo.'),
  bloqueado('Bloqueado',
      'No puedes hacer pedidos hasta que pasen 30 días desde el último que no recogiste.');

  final String etiqueta;
  final String descripcion;
  const NivelConfianza(this.etiqueta, this.descripcion);

  static NivelConfianza para(int noRecogidos,
      {int limite = AppConfig.limiteNoRecogidos}) {
    if (noRecogidos <= 0) return excelente;
    if (noRecogidos >= limite) return bloqueado;
    if (noRecogidos == limite - 1) return enRiesgo;
    return buena;
  }
}

class CuentaViewModel extends ChangeNotifier {
  final PerfilRepository _perfiles;
  final AuthRepository _auth;
  final PedidoRepository _pedidos;
  CuentaViewModel(this._perfiles, this._auth, this._pedidos) {
    cargar();
  }

  Perfil? perfil;
  int noRecogidos = 0;
  bool cargando = true;
  bool guardando = false;
  String? error;

  bool get esAlumno => perfil?.rol == RolUsuario.alumno;
  NivelConfianza get confianza => NivelConfianza.para(noRecogidos);
  int get limiteNoRecogidos => AppConfig.limiteNoRecogidos;

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      perfil = await _perfiles.miPerfil();
      if (esAlumno) noRecogidos = await _pedidos.noRecogidos();
      error = perfil == null ? 'No encontramos tu perfil.' : null;
    } catch (_) {
      error = 'No se pudo cargar tu cuenta.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Problema con los datos editados, o null si son válidos.
  String? validarDatos(String nombre, String telefono) {
    final n = nombre.trim();
    if (n.length < 2) return 'Escribe tu nombre completo.';
    if (n.length > 80) return 'El nombre es demasiado largo.';
    final t = RegistroViewModel.limpiarTelefono(telefono);
    if (t != null && !RegExp(r'^[0-9]{10}$').hasMatch(t)) {
      return 'El teléfono debe tener 10 dígitos.';
    }
    return null;
  }

  String? validarContrasena(String nueva, String confirmacion) {
    if (nueva.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (nueva != confirmacion) return 'Las contraseñas no coinciden.';
    return null;
  }

  Future<bool> editarDatos(String nombre, String telefono) => _ejecutar(
      () => _perfiles.editar(
          nombre.trim(), RegistroViewModel.limpiarTelefono(telefono)),
      'No se pudieron guardar tus datos.');

  Future<bool> cambiarContrasena(String actual, String nueva) => _ejecutar(
      () => _auth.cambiarContrasena(actual, nueva),
      'No se pudo cambiar la contraseña.',
      recargar: false);

  /// Confirma la contraseña, borra los datos personales y luego la cuenta.
  Future<bool> eliminarCuenta(String contrasena) => _ejecutar(() async {
        await _auth.reautenticar(contrasena);
        await _perfiles.eliminarMiCuenta();
        await _auth.eliminarCuentaActual();
      }, 'No se pudo eliminar la cuenta.', recargar: false);

  Future<bool> _ejecutar(Future<void> Function() accion, String porDefecto,
      {bool recargar = true}) async {
    if (guardando) return false;
    guardando = true;
    error = null;
    notifyListeners();
    try {
      await accion();
      if (recargar) await cargar();
      return true;
    } catch (e) {
      final texto = e.toString();
      error = texto.startsWith('Exception: ')
          ? texto.replaceFirst('Exception: ', '')
          : porDefecto;
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }
}
