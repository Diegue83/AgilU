import 'package:flutter/foundation.dart';

import '../../data/models/item_carrito.dart';
import '../../data/models/pedido.dart';
import '../../data/models/producto.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/pedido_repository.dart';

/// ViewModel compartido en toda la app (vive en el nivel más alto).
class CartViewModel extends ChangeNotifier {
  final Map<String, ItemCarrito> _items = {};

  List<ItemCarrito> get items => _items.values.toList();
  int get cantidadTotal => _items.values.fold(0, (s, e) => s + e.cantidad);
  double get total => _items.values.fold(0.0, (s, e) => s + e.subtotal);
  bool get vacio => _items.isEmpty;

  bool enviando = false;
  String? error;

  void agregar(Producto p) {
    final actual = _items[p.id];
    if (actual == null) {
      _items[p.id] = ItemCarrito(producto: p);
    } else {
      actual.cantidad++;
    }
    notifyListeners();
  }

  void quitarUno(String productoId) {
    final actual = _items[productoId];
    if (actual == null) return;
    if (actual.cantidad > 1) {
      actual.cantidad--;
    } else {
      _items.remove(productoId);
    }
    notifyListeners();
  }

  void eliminar(String productoId) {
    _items.remove(productoId);
    notifyListeners();
  }

  void limpiar() {
    _items.clear();
    notifyListeners();
  }

  /// Envía el pedido; devuelve el folio o null si falló.
  Future<String?> confirmar(AuthRepository auth, PedidoRepository repo) async {
    if (vacio) return null;
    enviando = true;
    error = null;
    notifyListeners();
    try {
      final pedido = Pedido(
        usuarioId: auth.uidActual ?? 'anonimo',
        items: items,
        total: total,
      );
      final folio = await repo.crearPedido(pedido);
      _items.clear();
      return folio;
    } catch (_) {
      error = 'No se pudo enviar el pedido. Intenta de nuevo.';
      return null;
    } finally {
      enviando = false;
      notifyListeners();
    }
  }
}
