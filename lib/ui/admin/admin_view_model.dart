import 'package:flutter/foundation.dart';

import '../../core/errores.dart';
import '../../data/models/perfil.dart';
import '../../data/models/personal.dart';
import '../../data/repositories/personal_repository.dart';

/// El administrador da de alta cafeterías y asigna roles a cualquier cuenta.
class AdminViewModel extends ChangeNotifier {
  final AdminRepository _repo;
  AdminViewModel(this._repo) {
    cargar();
  }

  static const _mensajes = [
    'Solo el administrador puede hacer esto',
    'La cafetería no existe',
  ];

  List<CafeteriaAdmin> cafeterias = [];
  List<MiembroPersonal> personal = [];
  bool cargando = true;
  String? error;

  List<CafeteriaAdmin> get cafeteriasActivas =>
      cafeterias.where((c) => c.activa).toList();

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      final r = await Future.wait([_repo.cafeterias(), _repo.personal()]);
      cafeterias = r[0] as List<CafeteriaAdmin>;
      personal = r[1] as List<MiembroPersonal>;
      error = null;
    } catch (e) {
      error = mensajeDeError(e, 'No se pudo cargar la información.', _mensajes);
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Roles que requieren una cafetería.
  static bool necesitaCafeteria(RolUsuario rol) =>
      rol == RolUsuario.encargado || rol == RolUsuario.empleado;

  String? validarNombreCafeteria(String nombre, {String? exceptoId}) {
    final n = nombre.trim();
    if (n.isEmpty) return 'Escribe el nombre de la cafetería.';
    if (n.length > 80) return 'El nombre es demasiado largo.';
    if (cafeterias.any((c) =>
        c.id != exceptoId && c.nombre.toLowerCase() == n.toLowerCase())) {
      return 'Ya existe una cafetería con ese nombre.';
    }
    return null;
  }

  static final _correoValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Problema con la asignación, o null si se puede enviar.
  String? validarAsignacion(
      String correo, RolUsuario rol, String? cafeteriaId) {
    if (!_correoValido.hasMatch(correo.trim())) {
      return 'El correo no es válido.';
    }
    if (necesitaCafeteria(rol) && cafeteriaId == null) {
      return 'Elige la cafetería.';
    }
    return null;
  }

  Future<bool> crearCafeteria(String nombre, String ubicacion) =>
      _ejecutar(() => _repo.crearCafeteria(
          nombre, ubicacion.trim().isEmpty ? null : ubicacion.trim()));

  Future<bool> editarCafeteria(CafeteriaAdmin c) =>
      _ejecutar(() => _repo.editarCafeteria(c));

  Future<bool> asignarRol(String correo, RolUsuario rol, String? cafeteriaId) =>
      _ejecutar(() => _repo.asignarRol(correo, rol,
          cafeteriaId: necesitaCafeteria(rol) ? cafeteriaId : null));

  Future<bool> _ejecutar(Future<void> Function() accion) async {
    try {
      await accion();
      await cargar();
      return true;
    } on CambioRechazado catch (e) {
      error = e.mensaje;
    } catch (e) {
      error = mensajeDeError(e, 'No se pudo guardar el cambio.', _mensajes);
    }
    notifyListeners();
    return false;
  }
}
