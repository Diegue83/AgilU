import 'package:firebase_data_connect/firebase_data_connect.dart';

import '../../core/conector.dart';
import '../../dataconnect_generated/agilu.dart';
import '../models/reporte.dart';

abstract class ReporteRepository {
  Future<List<FilaReporte>> resumen(DateTime desde, DateTime hasta);
}

class DataConnectReporteRepository implements ReporteRepository {
  final AgiluConnector _conector;
  DataConnectReporteRepository({AgiluConnector? conector})
      : _conector = conector ?? conectorAgilu;

  static Timestamp _ts(DateTime t) =>
      Timestamp(0, t.millisecondsSinceEpoch ~/ 1000);

  @override
  Future<List<FilaReporte>> resumen(DateTime desde, DateTime hasta) async {
    final res = await _conector
        .reporteBeneficiaria(desde: _ts(desde), hasta: _ts(hasta))
        .execute();
    return filasDe(res.data);
  }

  /// La respuesta de SQL nativo llega como List<AnyValue>; cada fila en .value.
  static List<FilaReporte> filasDe(ReporteBeneficiariaData d) =>
      (d.filas ?? const <AnyValue>[])
          .map((v) => FilaReporte.desdeMapa(v.value as Map))
          .toList();
}

class MockReporteRepository implements ReporteRepository {
  @override
  Future<List<FilaReporte>> resumen(DateTime desde, DateTime hasta) async =>
      const [
        FilaReporte(
          cafeteriaId: 'c1',
          cafeteria: 'Cafetería central',
          pedidos: 40,
          entregados: 34,
          noRecogidos: 2,
          cancelados: 3,
          ingresos: 2150,
          montoNoRecogido: 95,
        ),
        FilaReporte(
          cafeteriaId: 'c2',
          cafeteria: 'Barra de café',
          pedidos: 12,
          entregados: 12,
          ingresos: 420,
        ),
      ];
}
