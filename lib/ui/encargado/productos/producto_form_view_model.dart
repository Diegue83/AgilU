import 'package:flutter/foundation.dart';

import '../../../core/errores.dart';
import '../../../data/models/estacion.dart';
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

  ProductoFormViewModel(this._repo, List<Estacion> estaciones)
      : estaciones = estaciones.where((e) => e.activo).toList();

  static const _mensajes = [
    'El nombre es obligatorio',
    'El precio debe ser mayor a 0',
    'Elige una estación',
    'La estación no es de tu cafetería',
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
      await _repo.crear(DatosProducto(
        nombre: nombre.trim(),
        descripcion: descripcion.trim(),
        precio: leerPrecio(precio)!,
        estacionId: estacionId!,
        disponible: disponible,
      ));
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
