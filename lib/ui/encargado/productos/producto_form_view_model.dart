import 'package:flutter/foundation.dart';

import '../../../core/errores.dart';
import '../../../data/models/estacion.dart';
import '../../../data/models/producto.dart';
import '../../../data/repositories/producto_repository.dart';

/// Errores de validación del formulario, por campo.
class ErroresProducto {
  final String? nombre;
  final String? precio;
  final String? estacion;
  const ErroresProducto({this.nombre, this.precio, this.estacion});

  bool get hayErrores => nombre != null || precio != null || estacion != null;
}

class ProductoFormViewModel extends ChangeNotifier {
  final ProductoRepository _repo;
  final List<Estacion> estaciones;

  /// Producto que se edita; null cuando es un alta.
  final Producto? actual;

  ProductoFormViewModel(this._repo, List<Estacion> estaciones, {this.actual})
      : estaciones = estaciones
            .where((e) => e.activo || e.id == actual?.estacionId)
            .toList();

  bool get editando => actual != null;

  static const _mensajes = [
    'El nombre es obligatorio',
    'El precio debe ser mayor a 0',
    'Elige una estación',
    'La estación no es de tu cafetería',
    'El producto no es de tu cafetería',
    'El producto no existe',
  ];

  bool guardando = false;
  String? error;
  ErroresProducto errores = const ErroresProducto();

  static double? leerPrecio(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.').replaceAll(r'$', ''));

  ErroresProducto validar(String nombre, String precio, String? estacionId) {
    final p = leerPrecio(precio);
    return ErroresProducto(
      nombre: nombre.trim().isEmpty ? 'El nombre es obligatorio.' : null,
      precio: p == null
          ? 'Escribe un precio válido.'
          : p <= 0
              ? 'El precio debe ser mayor a 0.'
              : null,
      estacion: estacionId == null ? 'Elige una estación.' : null,
    );
  }

  /// Guarda el producto. Si falla, los datos del formulario se conservan
  /// porque viven en la vista; aquí solo se informa el motivo.
  /// Elimina el producto que se edita. Devuelve true si se eliminó.
  Future<bool> eliminar() async {
    if (!editando || guardando) return false;
    guardando = true;
    error = null;
    notifyListeners();
    try {
      await _repo.eliminar(actual!.id);
      return true;
    } catch (e) {
      error = mensajeDeError(e, 'No se pudo eliminar el producto.', _mensajes);
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  Future<bool> guardar({
    required String nombre,
    required String descripcion,
    required String precio,
    required String? estacionId,
    required bool disponible,
  }) async {
    if (guardando) return false;
    errores = validar(nombre, precio, estacionId);
    if (errores.hayErrores) {
      notifyListeners();
      return false;
    }
    guardando = true;
    error = null;
    notifyListeners();
    try {
      final datos = DatosProducto(
        nombre: nombre.trim(),
        descripcion: descripcion.trim(),
        precio: leerPrecio(precio)!,
        estacionId: estacionId!,
        disponible: disponible,
      );
      if (editando) {
        await _repo.editar(actual!.id, datos);
      } else {
        await _repo.crear(datos);
      }
      return true;
    } catch (e) {
      error = mensajeDeError(
          e, 'No se pudo guardar el producto. Intenta de nuevo.', _mensajes);
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }
}
