import 'package:flutter/foundation.dart';

import '../../core/app_config.dart';
import '../../core/reglas_pedido.dart';
import '../../data/models/cafeteria.dart';
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

  /// Cafetería de los productos del carrito, con su horario y capacidad.
  Cafeteria? cafeteria;
  Map<DateTime, int> _ocupacion = {};

  void configurarCafeteria(Cafeteria? c) {
    if (c == null || c.id == cafeteria?.id) return;
    if (_items.isNotEmpty && cafeteriaId != c.id) return;
    cafeteria = c;
    notifyListeners();
  }

  /// HU-10: carga cuántos pedidos tiene cada hora para marcar las llenas.
  Future<void> cargarOcupacion(PedidoRepository repo) async {
    final id = cafeteriaId;
    if (id == null) return;
    try {
      _ocupacion = await repo.ocupacion(id);
      notifyListeners();
    } catch (_) {
      _ocupacion = {};
    }
  }

  DateTime? recogerA;
  String notas = '';
  bool enviando = false;
  String? error;

  /// HU-07: minutos de anticipación que aplican a este carrito. Si la cocina
  /// lo permite y todo es de preparación inmediata, no se pide anticipación.
  int get anticipacionMinutos {
    final c = cafeteria;
    if (c == null) return AppConfig.anticipacionMinutos;
    final soloInmediatos = _items.isNotEmpty &&
        _items.values.every((i) => i.producto.preparacionInmediata);
    return c.permitirInmediatos && soloInmediatos ? 0 : c.anticipacionMinutos;
  }

  List<DateTime> get horasDisponibles {
    final c = cafeteria;
    if (c == null) return ReglasPedido.horasDisponibles(_ahora());
    return ReglasPedido.horasDisponibles(
      _ahora(),
      anticipacion: anticipacionMinutos,
      intervalo: c.intervaloMinutos,
      apertura: c.aperturaMinutos,
      cierre: c.cierreMinutos,
    );
  }

  /// Horas de hoy: las que no cumplen la anticipación aparecen antes,
  /// deshabilitadas, y las que ya se llenaron quedan marcadas.
  List<Franja> get franjas {
    final c = cafeteria;
    final capacidad = c?.capacidadPorFranja;
    final validas = horasDisponibles;
    final cercanas = c == null
        ? const <DateTime>[]
        : ReglasPedido.horasDisponibles(
            _ahora(),
            anticipacion: 0,
            intervalo: c.intervaloMinutos,
            apertura: c.aperturaMinutos,
            cierre: c.cierreMinutos,
          ).where((h) => !validas.contains(h)).toList();
    return [
      for (final h in cercanas) Franja(h, muyPronto: true),
      for (final h in validas)
        Franja(h,
            llena: capacidad != null && (_ocupacion[h] ?? 0) >= capacidad),
    ];
  }

  bool _horaLibre(DateTime h) =>
      franjas.any((f) => f.hora.isAtSameMomentAs(h) && f.elegible);

  bool agregar(Producto p) {
    if (_items.isNotEmpty && cafeteriaId != p.cafeteriaId) {
      error =
          'Tu carrito es de otra cafetería. Envía o vacía ese pedido primero.';
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
    if (!horasDisponibles.any((h) => h.isAtSameMomentAs(recogerA!))) {
      recogerA = null;
      notifyListeners();
      return 'Los pedidos requieren $anticipacionMinutos minutos de anticipación. Elige otra hora.';
    }
    if (!_horaLibre(recogerA!)) {
      recogerA = null;
      notifyListeners();
      return 'Esa hora ya se llenó. Elige otra.';
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
      final creado = await repo.crearPedido(pedido);
      final resultado = ResultadoPedido(
          id: creado.id,
          folio: creado.folio,
          recogerA: pedido.recogerA,
          total: pedido.total);
      _items.clear();
      recogerA = null;
      notas = '';
      return resultado;
    } on PedidoRechazado catch (e) {
      error = e.motivo;
      return null;
    } catch (_) {
      error =
          'No se pudo enviar el pedido. Revisa tu conexión e intenta de nuevo.';
      return null;
    } finally {
      enviando = false;
      notifyListeners();
    }
  }
}
