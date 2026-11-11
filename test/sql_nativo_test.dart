import 'package:agilu/data/repositories/dataconnect_pedido_repository.dart';
import 'package:agilu/data/repositories/panel_repository.dart';
import 'package:agilu/data/repositories/reporte_repository.dart';
import 'package:agilu/dataconnect_generated/agilu.dart';
import 'package:flutter_test/flutter_test.dart';

// Las respuestas de SQL nativo (_select, _selectFirst, _executeReturningFirst)
// llegan al SDK como AnyValue. Estas pruebas usan el JSON tal como lo regresa
// el servidor y los fromJson generados.
void main() {
  test('EntregarPedido: entregado, código incorrecto o no disponible', () {
    ResultadoEntrega r(Object? resultado) =>
        DataConnectPanelRepository.resultadoDe(
            EntregarPedidoData.fromJson({'resultado': resultado}));
    expect(
        r({'estado': 'entregado', 'intentos': 0}), ResultadoEntrega.entregado);
    expect(r({'estado': 'listo', 'intentos': 1}),
        ResultadoEntrega.codigoIncorrecto);
    expect(r(null), ResultadoEntrega.noDisponible);
  });

  test('DiagnosticarPedido trae el motivo', () {
    final d = DiagnosticarPedidoData.fromJson(const {
      'diagnostico': {'motivo': 'Esa hora ya se llenó. Elige otra.'},
    });
    expect(DataConnectPedidoRepository.motivoDe(d),
        'Esa hora ya se llenó. Elige otra.');
    expect(
        DataConnectPedidoRepository.motivoDe(
            DiagnosticarPedidoData.fromJson(const {'diagnostico': null})),
        isNull);
  });

  test('OcupacionFranjas convierte cada fila', () {
    final d = OcupacionFranjasData.fromJson(const {
      'franjas': [
        {'recogerA': '2026-11-11T08:00:00Z', 'pedidos': 3},
      ],
    });
    final o = DataConnectPedidoRepository.ocupacionDe(d);
    expect(o.values.single, 3);
    expect(o.keys.single.toUtc(), DateTime.utc(2026, 11, 11, 8));
  });

  test('MiConfianza trae el conteo de no recogidos', () {
    expect(
        DataConnectPedidoRepository.noRecogidosDe(
            MiConfianzaData.fromJson(const {
          'confianza': {'noRecogidos': 2},
        })),
        2);
    expect(
        DataConnectPedidoRepository.noRecogidosDe(
            MiConfianzaData.fromJson(const {'confianza': null})),
        0);
  });

  test('ReporteBeneficiaria convierte las filas', () {
    final filas = DataConnectReporteRepository.filasDe(
        ReporteBeneficiariaData.fromJson(const {
      'filas': [
        {
          'cafeteriaId': 'c0000000-0000-4000-8000-000000000001',
          'cafeteria': 'Cafetería central',
          'pedidos': 5,
          'entregados': 3,
          'noRecogidos': 1,
          'cancelados': 1,
          'ingresos': 250.0,
          'montoNoRecogido': 40.0,
        },
      ],
    }));
    expect(filas.single.cafeteria, 'Cafetería central');
    expect(filas.single.ingresos, 250);
  });
}
