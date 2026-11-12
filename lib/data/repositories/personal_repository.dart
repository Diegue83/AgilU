import 'package:firebase_data_connect/firebase_data_connect.dart';

import '../../core/conector.dart';
import '../../dataconnect_generated/agilu.dart';
import '../models/perfil.dart';
import '../models/personal.dart';

/// Lo que rechaza el servidor sin decir por qué (la operación no cambió nada).
class CambioRechazado implements Exception {
  final String mensaje;
  const CambioRechazado(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Empleados de la cafetería del encargado con sesión.
abstract class PersonalRepository {
  Future<List<MiembroPersonal>> miPersonal();

  /// Da de alta como empleado a una cuenta ya registrada que hoy es alumno.
  Future<void> agregarEmpleado(String correo);
  Future<void> quitarEmpleado(String usuarioId);
}

/// Operaciones del administrador: cafeterías y roles de cualquier cuenta.
abstract class AdminRepository {
  Future<List<CafeteriaAdmin>> cafeterias();
  Future<void> crearCafeteria(String nombre, String? ubicacion);
  Future<void> editarCafeteria(CafeteriaAdmin cafeteria);
  Future<List<MiembroPersonal>> personal();
  Future<void> asignarRol(String correo, RolUsuario rol, {String? cafeteriaId});
}

/// Las filas de SQL nativo llegan como List<AnyValue>; cada fila en .value.
List<Map> filasDeSql(List<AnyValue>? filas) =>
    (filas ?? const <AnyValue>[]).map((v) => v.value as Map).toList();

class DataConnectPersonalRepository implements PersonalRepository {
  final AgiluConnector _conector;
  DataConnectPersonalRepository({AgiluConnector? conector})
      : _conector = conector ?? conectorAgilu;

  @override
  Future<List<MiembroPersonal>> miPersonal() async {
    final res = await _conector.miPersonal().execute();
    return filasDeSql(res.data.personal)
        .map(MiembroPersonal.desdeMapa)
        .toList();
  }

  @override
  Future<void> agregarEmpleado(String correo) async {
    final res =
        await _conector.agregarEmpleado(correo: correo.trim()).execute();
    if (res.data.resultado == null) {
      throw const CambioRechazado(
          'No hay una cuenta de alumno con ese correo. La persona debe '
          'registrarse primero en la app.');
    }
  }

  @override
  Future<void> quitarEmpleado(String usuarioId) async {
    final res = await _conector.quitarEmpleado(usuarioId: usuarioId).execute();
    if (res.data.resultado == null) {
      throw const CambioRechazado(
          'Esa persona no es empleado de tu cafetería.');
    }
  }
}

class DataConnectAdminRepository implements AdminRepository {
  final AgiluConnector _conector;
  DataConnectAdminRepository({AgiluConnector? conector})
      : _conector = conector ?? conectorAgilu;

  @override
  Future<List<CafeteriaAdmin>> cafeterias() async {
    final res = await _conector.cafeteriasAdmin().execute();
    return filasDeSql(res.data.cafeterias)
        .map(CafeteriaAdmin.desdeMapa)
        .toList();
  }

  @override
  Future<void> crearCafeteria(String nombre, String? ubicacion) => _conector
      .crearCafeteriaAdmin(nombre: nombre.trim())
      .ubicacion(ubicacion)
      .execute();

  @override
  Future<void> editarCafeteria(CafeteriaAdmin c) => _conector
      .editarCafeteriaAdmin(id: c.id, nombre: c.nombre.trim(), activa: c.activa)
      .ubicacion(c.ubicacion)
      .execute();

  @override
  Future<List<MiembroPersonal>> personal() async {
    final res = await _conector.personalAdmin().execute();
    return filasDeSql(res.data.personal)
        .map(MiembroPersonal.desdeMapa)
        .toList();
  }

  @override
  Future<void> asignarRol(String correo, RolUsuario rol,
      {String? cafeteriaId}) async {
    var op = _conector.asignarRolAdmin(correo: correo.trim(), rol: rol.name);
    if (cafeteriaId != null) op = op.cafeteriaId(cafeteriaId);
    final res = await op.execute();
    if (res.data.resultado == null) {
      throw const CambioRechazado(
          'No se asignó el rol: revisa que la cuenta exista, que no sea la '
          'tuya y que la cafetería esté activa.');
    }
  }
}

class MockPersonalRepository implements PersonalRepository {
  final List<MiembroPersonal> personal = [
    const MiembroPersonal(
        usuarioId: 'u1',
        nombre: 'Encargada demo',
        correo: 'encargada@utng.edu.mx',
        rol: RolUsuario.encargado),
    const MiembroPersonal(
        usuarioId: 'u2',
        nombre: 'Luis',
        correo: 'luis@utng.edu.mx',
        rol: RolUsuario.empleado),
  ];

  /// Cuentas registradas como alumno que se pueden dar de alta.
  final Set<String> alumnos = {'nuevo@utng.edu.mx'};
  int _siguiente = 3;

  @override
  Future<List<MiembroPersonal>> miPersonal() async => List.of(personal);

  @override
  Future<void> agregarEmpleado(String correo) async {
    final c = correo.trim().toLowerCase();
    if (!alumnos.remove(c)) {
      throw const CambioRechazado(
          'No hay una cuenta de alumno con ese correo. La persona debe '
          'registrarse primero en la app.');
    }
    personal.add(MiembroPersonal(
        usuarioId: 'u${_siguiente++}',
        nombre: c.split('@').first,
        correo: c,
        rol: RolUsuario.empleado));
  }

  @override
  Future<void> quitarEmpleado(String usuarioId) async {
    final i = personal.indexWhere(
        (p) => p.usuarioId == usuarioId && p.rol == RolUsuario.empleado);
    if (i < 0) {
      throw const CambioRechazado(
          'Esa persona no es empleado de tu cafetería.');
    }
    alumnos.add(personal.removeAt(i).correo);
  }
}

class MockAdminRepository implements AdminRepository {
  final List<CafeteriaAdmin> _cafeterias = [
    const CafeteriaAdmin(
        id: 'c1', nombre: 'Cafetería central', ubicacion: 'Edificio A'),
  ];
  final List<MiembroPersonal> _personal = [];
  final Set<String> cuentas = {'nuevo@utng.edu.mx'};
  int _siguiente = 2;

  @override
  Future<List<CafeteriaAdmin>> cafeterias() async => List.of(_cafeterias);

  @override
  Future<void> crearCafeteria(String nombre, String? ubicacion) async =>
      _cafeterias.add(CafeteriaAdmin(
          id: 'c${_siguiente++}', nombre: nombre.trim(), ubicacion: ubicacion));

  @override
  Future<void> editarCafeteria(CafeteriaAdmin c) async {
    final i = _cafeterias.indexWhere((x) => x.id == c.id);
    _cafeterias[i] = c;
  }

  @override
  Future<List<MiembroPersonal>> personal() async => List.of(_personal);

  @override
  Future<void> asignarRol(String correo, RolUsuario rol,
      {String? cafeteriaId}) async {
    final c = correo.trim().toLowerCase();
    final conCafeteria =
        rol == RolUsuario.encargado || rol == RolUsuario.empleado;
    final cafeteria =
        _cafeterias.where((x) => x.id == cafeteriaId && x.activa).firstOrNull;
    if (!cuentas.contains(c) || (conCafeteria && cafeteria == null)) {
      throw const CambioRechazado(
          'No se asignó el rol: revisa que la cuenta exista, que no sea la '
          'tuya y que la cafetería esté activa.');
    }
    _personal.removeWhere((p) => p.correo == c);
    if (rol != RolUsuario.alumno) {
      _personal.add(MiembroPersonal(
        usuarioId: c,
        nombre: c.split('@').first,
        correo: c,
        rol: rol,
        cafeteriaId: conCafeteria ? cafeteria!.id : null,
        cafeteria: conCafeteria ? cafeteria!.nombre : null,
      ));
    }
  }
}
