import '../../core/reglas_pedido.dart';
import '../../dataconnect_generated/agilu.dart';
import '../models/ticket.dart';

/// El pago ya se validó o cambió de estado en otro dispositivo.
class PagoDesactualizado implements Exception {
  @override
  String toString() => 'Ese pago ya se había validado. Se actualizó la lista.';
}

abstract class PagosRepository {
  Future<List<PagoPorValidar>> porValidar();
  Future<void> validar(String pedidoId,
      {required bool aprobado, String? motivo});
}

class DataConnectPagosRepository implements PagosRepository {
  final AgiluConnector _conector;
  DataConnectPagosRepository({AgiluConnector? conector})
      : _conector = conector ?? AgiluConnector.instance;

  @override
  Future<List<PagoPorValidar>> porValidar() async {
    final res = await _conector.pagosPorValidar().execute();
    return res.data.pedidos
        .map((p) => PagoPorValidar(
              pedidoId: p.id,
              folio: ReglasPedido.formatearFolio(p.folio),
              referencia: p.referenciaPago ?? '',
              total: p.montoTotal,
              recogerA: p.recogerA.toDateTime().toLocal(),
              alumno: p.usuario.nombre,
              comprobanteUrl: p.comprobanteUrl,
            ))
        .toList();
  }

  @override
  Future<void> validar(String pedidoId,
      {required bool aprobado, String? motivo}) async {
    final res = await _conector
        .validarPago(id: pedidoId, aprobado: aprobado)
        .motivo(motivo)
        .execute();
    if ((res.data.execute_ ?? 0) == 0) throw PagoDesactualizado();
  }
}

class MockPagosRepository implements PagosRepository {
  final List<PagoPorValidar> pagos = [
    PagoPorValidar(
      pedidoId: 'p9',
      folio: 'AGU-00009',
      referencia: 'AGU-00009',
      total: 95,
      recogerA: DateTime.now().add(const Duration(hours: 1)),
      alumno: 'Ana',
    ),
  ];
  final Map<String, String?> resultados = {};

  @override
  Future<List<PagoPorValidar>> porValidar() async => List.of(pagos);

  @override
  Future<void> validar(String pedidoId,
      {required bool aprobado, String? motivo}) async {
    if (!pagos.any((p) => p.pedidoId == pedidoId)) throw PagoDesactualizado();
    pagos.removeWhere((p) => p.pedidoId == pedidoId);
    resultados[pedidoId] = aprobado ? null : motivo;
  }
}
