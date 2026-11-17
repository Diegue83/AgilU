import '../../../data/repositories/notificador.dart';
import 'package:flutter/foundation.dart';

import '../../../data/models/ticket.dart';
import '../../../data/repositories/pagos_repository.dart';

class PagosViewModel extends ChangeNotifier {
  final PagosRepository _repo;
  final Notificador? _avisos;
  PagosViewModel(this._repo, {Notificador? avisos}) : _avisos = avisos {
    cargar();
  }

  List<PagoPorValidar> pagos = [];
  bool cargando = true;
  String? error;

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      pagos = await _repo.porValidar();
      error = null;
    } catch (_) {
      error = 'No se pudieron cargar los pagos.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> aprobar(PagoPorValidar p) => _validar(p, true, null);

  /// Rechazar exige un motivo, que verá el alumno en su ticket.
  Future<bool> rechazar(PagoPorValidar p, String motivo) {
    if (motivo.trim().isEmpty) {
      error = 'Escribe el motivo del rechazo.';
      notifyListeners();
      return Future.value(false);
    }
    return _validar(p, false, motivo.trim());
  }

  Future<bool> _validar(PagoPorValidar p, bool aprobado, String? motivo) async {
    try {
      await _repo.validar(p.pedidoId, aprobado: aprobado, motivo: motivo);
      _avisos?.avisar(
          aprobado ? EventoAviso.pagoValidado : EventoAviso.pagoRechazado,
          pedidoId: p.pedidoId);
      await cargar();
      return true;
    } on PagoDesactualizado catch (e) {
      await cargar();
      error = e.toString();
      notifyListeners();
      return false;
    } catch (_) {
      error = 'No se pudo registrar la validación.';
      notifyListeners();
      return false;
    }
  }
}
