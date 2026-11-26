import 'package:flutter/foundation.dart';

import '../../core/errores.dart';
import '../../core/permisos.dart';
import '../../data/models/personal.dart';
import '../../data/models/rol.dart';
import '../../data/repositories/personal_repository.dart';

/// El administrador da de alta cafeterías, asigna roles a cualquier cuenta y
/// decide qué permisos tiene cada rol.
class AdminViewModel extends ChangeNotifier {
  final AdminRepository _repo;
  AdminViewModel(this._repo) {
    cargar();
  }

  static const _mensajes = [
    'No tienes permiso para hacer esto',
    'La cafetería no existe',
  ];

  List<CafeteriaAdmin> cafeterias = [];
  List<MiembroPersonal> personal = [];
  List<RolAdmin> roles = [];
  List<PermisoDisponible> permisos = [];
  bool cargando = true;
  String? error;

  List<CafeteriaAdmin> get cafeteriasActivas =>
      cafeterias.where((c) => c.activa).toList();

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      final r = await Future.wait([
        _repo.cafeterias(),
        _repo.personal(),
        _repo.roles(),
        _repo.permisos(),
      ]);
      cafeterias = r[0] as List<CafeteriaAdmin>;
      personal = r[1] as List<MiembroPersonal>;
      roles = r[2] as List<RolAdmin>;
      permisos = r[3] as List<PermisoDisponible>;
      error = null;
    } catch (e) {
      error = mensajeDeError(e, 'No se pudo cargar la información.', _mensajes);
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Los roles con permisos de cafetería requieren una cafetería.
  bool necesitaCafeteria(String rol) =>
      roles.where((r) => r.nombre == rol).firstOrNull?.requiereCafeteria ??
      false;

  static final _nombreRol = RegExp(r'^[a-z][a-z0-9_]{2,29}$');

  /// Problema con el nombre de un rol nuevo, o null si es válido.
  String? validarNombreRol(String nombre) {
    final n = nombre.trim();
    if (!_nombreRol.hasMatch(n)) {
      return 'Usa de 3 a 30 letras minúsculas, números o guion bajo, '
          'empezando con letra (ej. cajero).';
    }
    if (roles.any((r) => r.nombre == n)) {
      return 'Ya existe un rol con ese nombre.';
    }
    return null;
  }

  Future<bool> crearRol(String nombre, String descripcion) =>
      _ejecutar(() => _repo.crearRol(nombre.trim(),
          descripcion.trim().isEmpty ? null : descripcion.trim()));

  Future<bool> editarRol(RolAdmin r, String descripcion) =>
      _ejecutar(() => _repo.editarRol(
          r.id, descripcion.trim().isEmpty ? null : descripcion.trim()));

  Future<bool> eliminarRol(RolAdmin r) =>
      _ejecutar(() => _repo.eliminarRol(r.id));

  /// El alumno no lleva permisos y el administrador no pierde el suyo.
  bool puedeCambiar(RolAdmin r, String codigo) =>
      Permisos.sePuedeCambiar(r.nombre, codigo);

  Future<bool> cambiarPermiso(RolAdmin r, String codigo, bool activo) {
    if (!puedeCambiar(r, codigo)) return Future.value(false);
    return _ejecutar(() => _repo.cambiarPermiso(r.id, codigo, activo));
  }

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
  String? validarAsignacion(String correo, String rol, String? cafeteriaId) {
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

  Future<bool> asignarRol(String correo, String rol, String? cafeteriaId) =>
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
