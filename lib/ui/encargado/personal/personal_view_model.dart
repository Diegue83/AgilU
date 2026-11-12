import 'package:flutter/foundation.dart';

import '../../../core/errores.dart';
import '../../../data/models/personal.dart';
import '../../../data/repositories/personal_repository.dart';

/// El encargado da de alta y quita a los empleados de su cafetería.
class PersonalViewModel extends ChangeNotifier {
  final PersonalRepository _repo;
  PersonalViewModel(this._repo) {
    cargar();
  }

  List<MiembroPersonal> personal = [];
  bool cargando = true;
  String? error;

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      personal = await _repo.miPersonal();
      error = null;
    } catch (e) {
      error = mensajeDeError(e, 'No se pudo cargar el personal.', const []);
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  static final _correoValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Devuelve el problema con el correo, o null si se puede enviar.
  String? validarCorreo(String correo) {
    final c = correo.trim().toLowerCase();
    if (c.isEmpty) return 'Escribe el correo de la persona.';
    if (!_correoValido.hasMatch(c)) return 'El correo no es válido.';
    if (personal.any((p) => p.correo.toLowerCase() == c)) {
      return 'Esa persona ya forma parte del personal.';
    }
    return null;
  }

  Future<bool> agregar(String correo) =>
      _ejecutar(() => _repo.agregarEmpleado(correo));

  Future<bool> quitar(MiembroPersonal m) =>
      _ejecutar(() => _repo.quitarEmpleado(m.usuarioId));

  Future<bool> _ejecutar(Future<void> Function() accion) async {
    try {
      await accion();
      await cargar();
      return true;
    } on CambioRechazado catch (e) {
      error = e.mensaje;
    } catch (e) {
      error = mensajeDeError(e, 'No se pudo guardar el cambio.', const []);
    }
    notifyListeners();
    return false;
  }
}
