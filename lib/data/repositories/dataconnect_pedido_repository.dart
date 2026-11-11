import 'dart:math';

import 'package:firebase_data_connect/firebase_data_connect.dart';

import '../../core/reglas_pedido.dart';
import '../../dataconnect_generated/agilu.dart';
import '../models/pedido.dart';
import 'pedido_repository.dart';

/// Envía el pedido con la operación CrearPedido. El servidor toma los precios
/// del catálogo, calcula el total y asigna el folio; aquí solo se manda qué
/// productos y cuántos.
class DataConnectPedidoRepository implements PedidoRepository {
  final AgiluConnector _conector;
  final Random _azar;

  DataConnectPedidoRepository({AgiluConnector? conector, Random? azar})
      : _conector = conector ?? AgiluConnector.instance,
        _azar = azar ?? Random.secure();

  @override
  Future<String> crearPedido(Pedido pedido) async {
    final id = _uuidV4();
    final notas = pedido.notas.trim();
    final res = await _conector
        .crearPedido(
          id: id,
          cafeteriaId: pedido.cafeteriaId,
          recogerA:
              Timestamp(0, pedido.recogerA.millisecondsSinceEpoch ~/ 1000),
          items: AnyValue(itemsDe(pedido)),
        )
        .notas(notas.isEmpty ? null : notas)
        .execute();

    if ((res.data.execute_ ?? 0) == 0) {
      throw PedidoRechazado(await _motivoDelRechazo(pedido));
    }

    final consulta = await _conector.miPedido(id: id).execute();
    return ReglasPedido.formatearFolio(consulta.data.pedidos.single.folio);
  }

  Future<String> _motivoDelRechazo(Pedido pedido) async {
    try {
      final d = await _conector
          .diagnosticarPedido(
            cafeteriaId: pedido.cafeteriaId,
            recogerA: _timestamp(pedido.recogerA),
            items: AnyValue(itemsDe(pedido)),
          )
          .execute();
      final motivo = (d.data.diagnostico as Map?)?['motivo'];
      if (motivo is String && motivo.isNotEmpty) return motivo;
    } catch (_) {
      // Si tampoco se puede diagnosticar, se usa el mensaje general.
    }
    return 'La cafetería rechazó el pedido. Revisa tu carrito e intenta de nuevo.';
  }

  @override
  Future<Map<DateTime, int>> ocupacion(String cafeteriaId) async {
    final res =
        await _conector.ocupacionFranjas(cafeteriaId: cafeteriaId).execute();
    final filas = (res.data.franjas as List?) ?? const [];
    return {
      for (final f in filas.cast<Map>())
        DateTime.parse(f['recogerA'] as String).toLocal():
            (f['pedidos'] as num).toInt(),
    };
  }

  static Timestamp _timestamp(DateTime t) =>
      Timestamp(0, t.millisecondsSinceEpoch ~/ 1000);

  static List<Map<String, dynamic>> itemsDe(Pedido pedido) => [
        for (final i in pedido.items)
          {'productoId': i.producto.id, 'cantidad': i.cantidad},
      ];

  String _uuidV4() {
    final b = List<int>.generate(16, (_) => _azar.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }
}
