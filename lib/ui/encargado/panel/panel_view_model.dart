import 'dart:async';

import 'package:flutter/foundation.dart';

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

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
