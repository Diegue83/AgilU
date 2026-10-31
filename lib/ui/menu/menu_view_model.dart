import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/producto.dart';
import '../../data/repositories/menu_repository.dart';

class MenuViewModel extends ChangeNotifier {
  final MenuRepository _repo;
  StreamSubscription<List<Producto>>? _sub;

  MenuViewModel(this._repo) {
    _sub = _repo.observarMenu().listen(
      (lista) {
        _productos = List.of(lista)
          ..sort((a, b) {
            final c = a.estacionOrden.compareTo(b.estacionOrden);
            return c != 0 ? c : a.nombre.compareTo(b.nombre);
          });
        cargando = false;
        error = null;
        notifyListeners();
      },
      onError: (Object e) {
        cargando = false;
        error = 'No se pudo cargar el menú.';
        notifyListeners();
      },
    );
  }

  List<Producto> _productos = [];
  bool cargando = true;
  String? error;
  String? categoriaSeleccionada; // null = todas

  /// Secciones en el orden de las estaciones que definió el encargado.
  List<String> get categorias =>
      _productos.map((p) => p.seccion).toSet().toList();

  List<Producto> get productosVisibles => categoriaSeleccionada == null
      ? _productos
      : _productos.where((p) => p.seccion == categoriaSeleccionada).toList();

  void seleccionarCategoria(String? categoria) {
    categoriaSeleccionada = categoria;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
