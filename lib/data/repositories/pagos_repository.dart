import 'dart:typed_data';

import '../../core/conector.dart';
import '../../core/reglas_pedido.dart';
import '../../dataconnect_generated/agilu.dart';
import '../models/ticket.dart';
import 'almacen_archivos.dart';

/// El pago ya se validó o cambió de estado en otro dispositivo.
class PagoDesactualizado implements Exception {
  @override
  String toString() => 'Ese pago ya se había validado. Se actualizó la lista.';
}

abstract class PagosRepository {
  Future<List<PagoPorValidar>> porValidar();
  Future<void> validar(String pedidoId,
      {required bool aprobado, String? motivo});

  /// Imagen de un comprobante guardado en Supabase (su ruta en el bucket).
  Future<Uint8List> comprobante(String ruta);
}

class DataConnectPagosRepository implements PagosRepository {
  final AgiluConnector _conector;
  final AlmacenArchivos? _almacen;
  DataConnectPagosRepository(
      {AgiluConnector? conector, AlmacenArchivos? almacen})
      : _conector = conector ?? conectorAgilu,
        _almacen = almacen;

  @override
  Future<Uint8List> comprobante(String ruta) {
    final almacen = _almacen;
    if (almacen == null) {
      throw Exception('El almacenamiento de comprobantes no está configurado.');
    }
    return almacen.descargar('comprobantes', ruta);
  }

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

  /// Imágenes de comprobante por ruta, para pruebas.
  final Map<String, Uint8List> imagenes = {};

  @override
  Future<Uint8List> comprobante(String ruta) async {
    final i = imagenes[ruta];
    if (i == null) throw Exception('No existe el comprobante.');
    return i;
  }
}
