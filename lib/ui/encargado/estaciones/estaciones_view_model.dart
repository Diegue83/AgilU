import 'package:flutter/foundation.dart';

import '../../../core/errores.dart';
import '../../../data/models/estacion.dart';
import '../../../data/repositories/estacion_repository.dart';

class EstacionesViewModel extends ChangeNotifier {
  final EstacionRepository _repo;
  EstacionesViewModel(this._repo) {
    cargar();
  }

  static const _mensajes = [
    'La estación tiene productos: desactívala en lugar de borrarla',
    'Solo el encargado puede hacer esto',
    'No tienes cafetería asignada',
    'La estación no es de tu cafetería',
  ];

  List<Estacion> estaciones = [];
  bool cargando = true;
  String? error;

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      estaciones = await _repo.misEstaciones();
      error = null;
    } catch (e) {
      error = mensajeDeError(e, 'No se pudieron cargar las estaciones.', _mensajes);
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Devuelve el problema con el nombre, o null si es válido.
  String? validarNombre(String nombre, {String? exceptoId}) {
    final limpio = nombre.trim();
    if (limpio.isEmpty) return 'Escribe el nombre de la estación.';
    final repetido = estaciones.any((e) =>
        e.id != exceptoId && e.nombre.toLowerCase() == limpio.toLowerCase());
    if (repetido) return 'Ya existe una estación con ese nombre.';
    return null;
  }

  Future<bool> crear(String nombre) => _ejecutar(() {
        final orden = estaciones.isEmpty
            ? 1
            : estaciones.map((e) => e.orden).reduce((a, b) => a > b ? a : b) + 1;
        return _repo.crear(nombre.trim(), orden);
      });

  Future<bool> renombrar(Estacion e, String nombre) =>
      _ejecutar(() => _repo.editar(e.copiar(nombre: nombre.trim())));

  Future<bool> alternarActiva(Estacion e) =>
      _ejecutar(() => _repo.editar(e.copiar(activo: !e.activo)));

  Future<bool> eliminar(Estacion e) => _ejecutar(() => _repo.eliminar(e.id));

  /// Mueve la estación una posición arriba (-1) o abajo (+1) y guarda el
  /// nuevo orden de las dos estaciones intercambiadas.
  Future<bool> mover(Estacion e, int direccion) {
    final i = estaciones.indexOf(e);
    final j = i + direccion;
    if (i < 0 || j < 0 || j >= estaciones.length) return Future.value(false);
    final otra = estaciones[j];
    return _ejecutar(() async {
      await _repo.editar(e.copiar(orden: j + 1));
      await _repo.editar(otra.copiar(orden: i + 1));
    });
  }

  Future<bool> _ejecutar(Future<void> Function() accion) async {
    try {
      await accion();
      await cargar();
      return true;
    } catch (e) {
      error = mensajeDeError(e, 'No se pudo guardar el cambio.', _mensajes);
      notifyListeners();
      return false;
    }
  }
}
