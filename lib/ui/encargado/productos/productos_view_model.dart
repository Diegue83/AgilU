import 'package:flutter/foundation.dart';

import '../../../core/errores.dart';
import '../../../data/models/estacion.dart';
import '../../../data/models/producto.dart';
import '../../../data/repositories/estacion_repository.dart';
import '../../../data/repositories/producto_repository.dart';

class ProductosViewModel extends ChangeNotifier {
  final ProductoRepository _productos;
  final EstacionRepository _estaciones;

  ProductosViewModel(this._productos, this._estaciones) {
    cargar();
  }

  List<Producto> _todos = [];
  List<Estacion> estaciones = [];
  bool cargando = true;
  String? error;
  String? estacionSeleccionada; // null = todas
  String busqueda = '';

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      final productos = await _productos.misProductos();
      final estaciones = await _estaciones.misEstaciones();
      _todos = productos;
      this.estaciones = estaciones;
      error = null;
    } catch (e) {
      error =
          mensajeDeError(e, 'No se pudieron cargar los productos.', const []);
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  List<Producto> get visibles {
    final texto = _normalizar(busqueda);
    return _todos
        .where((p) =>
            estacionSeleccionada == null ||
            p.estacionId == estacionSeleccionada)
        .where((p) => texto.isEmpty || _normalizar(p.nombre).contains(texto))
        .toList()
      ..sort((a, b) {
        final c = a.estacionOrden.compareTo(b.estacionOrden);
        return c != 0 ? c : a.nombre.compareTo(b.nombre);
      });
  }

  int get total => _todos.length;

  void seleccionarEstacion(String? id) {
    estacionSeleccionada = id;
    notifyListeners();
  }

  void buscar(String texto) {
    busqueda = texto;
    notifyListeners();
  }

  static String _normalizar(String s) => s
      .toLowerCase()
      .trim()
      .replaceAll(RegExp('[áä]'), 'a')
      .replaceAll(RegExp('[éë]'), 'e')
      .replaceAll(RegExp('[íï]'), 'i')
      .replaceAll(RegExp('[óö]'), 'o')
      .replaceAll(RegExp('[úü]'), 'u');
}
