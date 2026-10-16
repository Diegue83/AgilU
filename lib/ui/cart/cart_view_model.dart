import 'package:flutter/foundation.dart';

import '../../core/reglas_pedido.dart';
import '../../data/models/item_carrito.dart';
import '../../data/models/pedido.dart';
import '../../data/models/producto.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/pedido_repository.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel({DateTime Function()? ahora}) : _ahora = ahora ?? DateTime.now;

  final DateTime Function() _ahora;
  final Map<String, ItemCarrito> _items = {};

  List<ItemCarrito> get items => _items.values.toList();
  int get cantidadTotal => _items.values.fold(0, (s, e) => s + e.cantidad);
  double get total => _items.values.fold(0.0, (s, e) => s + e.subtotal);
  bool get vacio => _items.isEmpty;

  String? get cafeteriaId =>
      _items.isEmpty ? null : _items.values.first.producto.cafeteriaId;

  DateTime? recogerA;
  String notas = '';
  bool enviando = false;
  String? error;

  List<DateTime> get horasDisponibles => ReglasPedido.horasDisponibles(_ahora());

  bool agregar(Producto p) {
    if (_items.isNotEmpty && cafeteriaId != p.cafeteriaId) {
      error = 'Tu carrito es de otra cafetería. Envía o vacía ese pedido primero.';
      notifyListeners();
      return false;
    }
    error = null;
    final actual = _items[p.id];
    if (actual == null) {
      _items[p.id] = ItemCarrito(producto: p);
    } else {
      actual.cantidad++;
    }
    notifyListeners();
    return true;
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

  void elegirHora(DateTime? hora) {
    recogerA = hora;
    error = null;
    notifyListeners();
  }

  void escribirNotas(String texto) => notas = texto;

  void limpiar() {
    _items.clear();
    recogerA = null;
    notas = '';
    error = null;
    notifyListeners();
  }

  String? validar() {
    if (vacio) return 'Tu carrito está vacío.';
    if (recogerA == null) return 'Elige la hora a la que vas a recoger.';
    if (!ReglasPedido.horaValida(recogerA!, _ahora())) {
      recogerA = null;
      notifyListeners();
      return 'Esa hora ya no cumple con 1 hora de anticipación. Elige otra.';
    }
    return null;
  }

  Future<ResultadoPedido?> confirmar(
      AuthRepository auth, PedidoRepository repo) async {
    if (enviando) return null;
    final problema = validar();
    if (problema != null) {
      error = problema;
      notifyListeners();
      return null;
    }
    final uid = auth.uidActual;
    if (uid == null) {
      error = 'Inicia sesión para enviar tu pedido.';
      notifyListeners();
      return null;
    }

    enviando = true;
    error = null;
    notifyListeners();
    try {
      final pedido = Pedido(
        usuarioId: uid,
        cafeteriaId: cafeteriaId!,
        items: items,
        total: total,
        recogerA: recogerA!,
        notas: notas,
      );
      final folio = await repo.crearPedido(pedido);
      final resultado = ResultadoPedido(
          folio: folio, recogerA: pedido.recogerA, total: pedido.total);
      _items.clear();
      recogerA = null;
      notas = '';
      return resultado;
    } catch (_) {
      error = 'No se pudo enviar el pedido. Revisa tu conexión e intenta de nuevo.';
      return null;
    } finally {
      enviando = false;
      notifyListeners();
    }
  }
}