import 'package:flutter/foundation.dart';

import '../../data/models/reporte.dart';
import '../../data/repositories/reporte_repository.dart';

class ReporteViewModel extends ChangeNotifier {
  final ReporteRepository _repo;
  final DateTime Function() _ahora;

  ReporteViewModel(this._repo, {DateTime Function()? ahora})
      : _ahora = ahora ?? DateTime.now {
    cargar();
  }

  Periodo periodo = Periodo.semana;
  List<FilaReporte> filas = [];
  bool cargando = true;
  String? error;

  FilaReporte get total => FilaReporte.total(filas);

  Future<void> elegir(Periodo p) async {
    periodo = p;
    await cargar();
  }

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      final (desde, hasta) = periodo.rango(_ahora());
      filas = await _repo.resumen(desde, hasta);
      error = null;
    } catch (_) {
      error = 'No se pudo cargar el reporte.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
