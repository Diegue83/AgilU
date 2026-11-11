import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/cafeteria.dart';
import '../../data/models/producto.dart';
import '../../data/repositories/menu_repository.dart';

class MenuViewModel extends ChangeNotifier {
  final MenuRepository _repo;
  final DateTime Function() _ahora;
  StreamSubscription<List<Producto>>? _sub;

  MenuViewModel(this._repo, {DateTime Function()? ahora})
      : _ahora = ahora ?? DateTime.now {
    _repo.cafeterias().then((lista) {
      cafeterias = lista;
      cafeteriaSeleccionada ??= lista.isEmpty ? null : lista.first.id;
      _cafeteriasListas = true;
      _actualizarCargando();
    }, onError: (Object _) {
      error = 'No se pudo cargar el menú.';
      _cafeteriasListas = true;
      _actualizarCargando();
    });
    _sub = _repo.observarMenu().listen(
      (lista) {
        _productos = List.of(lista);
        _menuListo = true;
        error = null;
        _actualizarCargando();
      },
      onError: (Object e) {
        error = 'No se pudo cargar el menú.';
        _menuListo = true;
        _actualizarCargando();
      },
    );
  }

  List<Producto> _productos = [];
  List<Cafeteria> cafeterias = [];
  String? cafeteriaSeleccionada;
  bool _cafeteriasListas = false;
  bool _menuListo = false;
  bool cargando = true;
  String? error;
  String? categoriaSeleccionada; // null = todas

  void _actualizarCargando() {
    cargando = !(_cafeteriasListas && _menuListo);
    notifyListeners();
  }

  Cafeteria? get cafeteria {
    for (final c in cafeterias) {
      if (c.id == cafeteriaSeleccionada) return c;
    }
    return null;
  }

  /// Productos de hoy en la cafetería elegida: primero los disponibles, en el
  /// orden de las estaciones; los agotados al final.
  List<Producto> get _deHoy => _productos
      .where((p) =>
          cafeteriaSeleccionada == null ||
          p.cafeteriaId == cafeteriaSeleccionada)
      .toList()
    ..sort((a, b) {
      if (a.disponible != b.disponible) return a.disponible ? -1 : 1;
      final c = a.estacionOrden.compareTo(b.estacionOrden);
      return c != 0 ? c : a.nombre.compareTo(b.nombre);
    });

  /// Secciones en el orden de las estaciones que definió el encargado.
  List<String> get categorias {
    final porOrden = List.of(_deHoy)
      ..sort((a, b) => a.estacionOrden.compareTo(b.estacionOrden));
    return porOrden.map((p) => p.seccion).toSet().toList();
  }

  /// HU-21: ofertas vigentes y especialidades disponibles de la cafetería.
  List<Producto> get destacados =>
      _deHoy.where((p) => p.disponible && p.destacadoEn(_ahora())).toList();

  DateTime get ahora => _ahora();

  List<Producto> get productosVisibles => categoriaSeleccionada == null
      ? _deHoy
      : _deHoy.where((p) => p.seccion == categoriaSeleccionada).toList();

  bool get puedePedir {
    final c = cafeteria;
    return c != null &&
        c.recibePedidosHoy(_ahora()) &&
        _deHoy.any((p) => p.disponible);
  }

  /// Aviso que se muestra arriba del menú, o null si todo está normal.
  String? get aviso {
    final c = cafeteria;
    if (cafeterias.isEmpty || c == null) {
      return 'Por ahora no hay cafeterías abiertas.';
    }
    final ahora = _ahora();
    if (!c.recibePedidosHoy(ahora)) {
      return '${c.nombre} ya no recibe pedidos hoy. '
          'Abre mañana a las ${Cafeteria.hora(c.aperturaMinutos)}.';
    }
    if (_deHoy.isEmpty) return 'Hoy no hay menú cargado en ${c.nombre}.';
    if (!_deHoy.any((p) => p.disponible)) {
      return 'Todo el menú de hoy está agotado en ${c.nombre}.';
    }
    if (!c.abiertaAhora(ahora)) {
      return '${c.nombre} abre a las ${Cafeteria.hora(c.aperturaMinutos)}. '
          'Ya puedes programar tu pedido.';
    }
    return null;
  }

  void seleccionarCafeteria(String id) {
    cafeteriaSeleccionada = id;
    categoriaSeleccionada = null;
    notifyListeners();
  }

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
