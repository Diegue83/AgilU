import 'package:flutter/foundation.dart';

import '../../core/errores.dart';
import '../../data/models/ticket.dart';
import '../../data/repositories/pedido_repository.dart';

class TicketViewModel extends ChangeNotifier {
  final PedidoRepository _repo;
  final String pedidoId;
  TicketViewModel(this._repo, this.pedidoId) {
    cargar();
  }

  TicketPedido? ticket;
  bool cargando = true;
  bool subiendo = false;
  String? error;

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      ticket = await _repo.ticket(pedidoId);
      error = ticket == null ? 'No encontramos este pedido.' : null;
    } catch (_) {
      error = 'No se pudo cargar el pedido.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> subirComprobante(Uint8List bytes, String tipo) async {
    if (subiendo || !(ticket?.esperaComprobante ?? false)) return false;
    subiendo = true;
    error = null;
    notifyListeners();
    try {
      await _repo.subirComprobante(pedidoId, bytes, tipo);
      await cargar();
      return true;
    } catch (e) {
      error = mensajeDeError(e, 'No se pudo subir el comprobante.', const [
        'La foto pesa más de 1 MB.',
        'La foto debe ser JPG o PNG.',
        'El archivo no es una imagen válida.',
        'Este pedido ya no espera comprobante.',
      ]);
      return false;
    } finally {
      subiendo = false;
      notifyListeners();
    }
  }
}
