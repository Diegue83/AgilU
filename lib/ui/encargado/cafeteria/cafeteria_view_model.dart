import 'package:flutter/foundation.dart';

import '../../../core/errores.dart';
import '../../../data/models/cafeteria.dart';
import '../../../data/repositories/cafeteria_repository.dart';

class CafeteriaViewModel extends ChangeNotifier {
  final CafeteriaRepository _repo;
  CafeteriaViewModel(this._repo) {
    cargar();
  }

  Cafeteria? cafeteria;
  bool cargando = true;
  bool guardando = false;
  String? error;
  String? mensaje;

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      cafeteria = await _repo.miCafeteria();
      error = cafeteria == null ? 'No tienes cafetería asignada.' : null;
    } catch (e) {
      error = 'No se pudieron cargar los ajustes.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  void cambiar(Cafeteria c) {
    cafeteria = c;
    mensaje = null;
    error = c.validar();
    notifyListeners();
  }

  Future<bool> guardar() async {
    final c = cafeteria;
    if (c == null || guardando) return false;
    error = c.validar();
    if (error != null) {
      notifyListeners();
      return false;
    }
    guardando = true;
    notifyListeners();
    try {
      await _repo.guardar(c);
      mensaje = 'Ajustes guardados.';
      return true;
    } catch (e) {
      error = mensajeDeError(e, 'No se pudieron guardar los ajustes.', const [
        'El horario no es válido',
        'La anticipación debe estar entre 0 y 240 minutos',
        'El intervalo debe estar entre 5 y 60 minutos',
        'La capacidad debe estar entre 1 y 200 pedidos',
        'Solo el encargado puede hacer esto',
      ]);
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }
}
