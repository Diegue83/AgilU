import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/codigo_qr.dart';
import '../../../data/models/pedido_panel.dart';
import '../../../data/repositories/panel_repository.dart';

class PanelViewModel extends ChangeNotifier {
  final PanelRepository _repo;
  StreamSubscription<List<PedidoPanel>>? _sub;

  PanelViewModel(this._repo) {
    _sub = _repo.observarHoy().listen(
      (lista) {
        _pedidos = lista;
        cargando = false;
        error = null;
        notifyListeners();
      },
      onError: (Object _) {
        cargando = false;
        error =
            'No se pudo actualizar el panel. Se reintentará en unos segundos.';
        notifyListeners();
      },
    );
  }

  List<PedidoPanel> _pedidos = [];
  bool cargando = true;
  String? error;
  final Set<String> _avanzando = {};

  /// Pedidos del estado indicado en orden de hora de recogida y folio.
  List<PedidoPanel> enEstado(EstadoPedido e) =>
      _pedidos.where((p) => p.estado == e).toList()
        ..sort((a, b) {
          final c = a.recogerA.compareTo(b.recogerA);
          return c != 0 ? c : a.folio.compareTo(b.folio);
        });

  bool avanzando(PedidoPanel p) => _avanzando.contains(p.id);

  Future<void> avanzar(PedidoPanel p) async {
    if (_avanzando.contains(p.id) || p.estado.siguiente == null) return;
    _avanzando.add(p.id);
    notifyListeners();
    try {
      await _repo.avanzar(p);
      final i = _pedidos.indexWhere((x) => x.id == p.id);
      if (i >= 0) _pedidos[i] = p.conEstado(p.estado.siguiente!);
      error = null;
    } on PedidoDesactualizado catch (e) {
      error = e.toString();
    } catch (_) {
      error = 'No se pudo cambiar el estado. Intenta de nuevo.';
    } finally {
      _avanzando.remove(p.id);
      notifyListeners();
    }
  }

  String? mensaje;

  /// HU-09: entrega con el PIN que dicta o muestra el alumno.
  Future<bool> entregar(PedidoPanel p, String codigo) async {
    if (!RegExp(r'^\d{4}$').hasMatch(codigo.trim())) {
      error = 'El código tiene 4 dígitos.';
      notifyListeners();
      return false;
    }
    try {
      final r = await _repo.entregar(p.id, codigo);
      switch (r) {
        case ResultadoEntrega.entregado:
          _pedidos.removeWhere((x) => x.id == p.id);
          error = null;
          mensaje = 'Pedido ${p.folio} entregado.';
          notifyListeners();
          return true;
        case ResultadoEntrega.codigoIncorrecto:
          error =
              'Código incorrecto. Pide al alumno que lo revise en su ticket.';
        case ResultadoEntrega.noDisponible:
          error = 'Este pedido ya no se puede entregar con código. '
              'Si hubo varios intentos fallidos, verifica la identidad del alumno.';
      }
    } catch (_) {
      error = 'No se pudo registrar la entrega.';
    }
    notifyListeners();
    return false;
  }

  /// HU-12: entrega con el QR que muestra el alumno. Un QR de otro pedido, de
  /// otra cafetería o ya usado se rechaza.
  Future<bool> entregarConQr(String texto) async {
    final qr = CodigoQr.leer(texto);
    if (qr == null) {
      error = 'Ese QR no es un código de entrega de ÁgilU.';
      notifyListeners();
      return false;
    }
    final id = CodigoQr.normalizarId(qr.pedidoId);
    PedidoPanel? pedido;
    for (final p in _pedidos) {
      if (CodigoQr.normalizarId(p.id) == id) pedido = p;
    }
    if (pedido == null || pedido.estado != EstadoPedido.listo) {
      error =
          'Ese QR no corresponde a un pedido listo de tu cafetería o ya se usó.';
      notifyListeners();
      return false;
    }
    return entregar(pedido, qr.codigo);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
