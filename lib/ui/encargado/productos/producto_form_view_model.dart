import 'package:flutter/foundation.dart';

import '../../../core/errores.dart';
import '../../../data/models/estacion.dart';
import '../../../data/models/producto.dart';
import '../../../data/repositories/foto_repository.dart';
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

  final FotoRepository? _fotos;

  ProductoFormViewModel(this._repo, List<Estacion> estaciones,
      {this.actual, FotoRepository? fotos})
      : _fotos = fotos,
        urlImagen = actual?.urlImagen,
        estaciones = estaciones
            .where((e) => e.activo || e.id == actual?.estacionId)
            .toList();

  String? urlImagen;
  bool subiendoFoto = false;

  /// La foto se puede cambiar una vez que el producto existe.
  bool get puedeTenerFoto => editando && _fotos != null;

  Future<bool> subirFoto(Uint8List bytes, String tipo) async {
    if (!puedeTenerFoto || subiendoFoto) return false;
    subiendoFoto = true;
    error = null;
    notifyListeners();
    try {
      urlImagen = await _fotos!.subir(actual!.id, bytes, tipo);
      return true;
    } catch (e) {
      error = mensajeDeError(e, 'No se pudo guardar la foto.', const [
        'La foto pesa más de 1 MB.',
        'La foto debe ser JPG o PNG.',
        'El archivo no es una imagen válida.',
        'El producto no es de tu cafetería.',
      ]);
      return false;
    } finally {
      subiendoFoto = false;
      notifyListeners();
    }
  }

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
  static const _mensajesOferta = [
    'El precio de oferta debe ser mayor a 0',
    'La fecha de término ya pasó',
    'La oferta debe costar menos que el precio normal',
    'El producto no es de tu cafetería',
  ];

  /// HU-21: valida la oferta. Devuelve el problema o null.
  String? validarOferta(String precioTexto, DateTime? hasta, DateTime ahora) {
    final p = leerPrecio(precioTexto);
    if (p == null || p <= 0) return 'Escribe un precio de oferta mayor a 0.';
    if (actual != null && p >= actual!.precio) {
      return 'La oferta debe costar menos que el precio normal.';
    }
    if (hasta == null || !hasta.isAfter(ahora)) {
      return 'Elige una fecha de término futura.';
    }
    return null;
  }

  String? errorOferta;

  Future<bool> publicarOferta(String precioTexto, DateTime? hasta,
      bool esEspecialidad, DateTime ahora) async {
    if (!editando || guardando) return false;
    errorOferta = validarOferta(precioTexto, hasta, ahora);
    if (errorOferta != null) {
      notifyListeners();
      return false;
    }
    guardando = true;
    notifyListeners();
    try {
      await _repo.publicarOferta(
          actual!.id, leerPrecio(precioTexto)!, hasta!, esEspecialidad);
      return true;
    } catch (e) {
      errorOferta =
          mensajeDeError(e, 'No se pudo publicar la oferta.', _mensajesOferta);
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  Future<bool> quitarOferta() async {
    if (!editando || guardando) return false;
    guardando = true;
    notifyListeners();
    try {
      await _repo.quitarOferta(actual!.id);
      return true;
    } catch (e) {
      errorOferta =
          mensajeDeError(e, 'No se pudo quitar la oferta.', _mensajesOferta);
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

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
