import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';

import '../../core/conector.dart';
import '../../core/reglas_pedido.dart';
import '../../dataconnect_generated/agilu.dart';
import '../models/pedido.dart';
import '../models/pedido_panel.dart';
import '../models/ticket.dart';
import 'pedido_repository.dart';

/// Envía el pedido con la operación CrearPedido. El servidor toma los precios
/// del catálogo, calcula el total y asigna el folio; aquí solo se manda qué
/// productos y cuántos.
class DataConnectPedidoRepository implements PedidoRepository {
  final AgiluConnector _conector;
  final Random _azar;
  final FirebaseFunctions? _functions;

  DataConnectPedidoRepository(
      {AgiluConnector? conector, Random? azar, FirebaseFunctions? functions})
      : _conector = conector ?? conectorAgilu,
        _azar = azar ?? Random.secure(),
        _functions = functions;

  @override
  Future<PedidoCreado> crearPedido(Pedido pedido) async {
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
    final creado = consulta.data.pedidos.single;
    return PedidoCreado(creado.id, ReglasPedido.formatearFolio(creado.folio));
  }

  @override
  Future<int> noRecogidos() async {
    final res = await _conector.miConfianza().execute();
    final fila = res.data.confianza as Map?;
    return (fila?['noRecogidos'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<List<ResumenPedido>> misPedidos() async {
    final res = await _conector.misPedidos().execute();
    return res.data.pedidos
        .map((p) => ResumenPedido(
              id: p.id,
              folio: ReglasPedido.formatearFolio(p.folio),
              estado: EstadoPedido.desdeNombre(p.estado),
              recogerA: p.recogerA.toDateTime().toLocal(),
              total: p.montoTotal,
              cafeteria: p.cafeteria.nombre,
            ))
        .toList();
  }

  @override
  Future<TicketPedido?> ticket(String id) async {
    final res = await _conector.miPedido(id: id).execute();
    if (res.data.pedidos.isEmpty) return null;
    final p = res.data.pedidos.single;
    final folio = ReglasPedido.formatearFolio(p.folio);
    return TicketPedido(
      id: p.id,
      folio: folio,
      referencia: p.referenciaPago ?? folio,
      estado: EstadoPedido.desdeNombre(p.estado),
      recogerA: p.recogerA.toDateTime().toLocal(),
      total: p.montoTotal,
      notas: p.notas,
      cafeteria: p.cafeteria.nombre,
      ubicacion: p.cafeteria.ubicacion,
      banco: p.cafeteria.banco,
      clabe: p.cafeteria.clabe,
      titular: p.cafeteria.titular,
      motivoRechazo: p.motivoRechazoPago,
      pagadoEn: p.pagadoEn?.toDateTime().toLocal(),
      codigoEntrega: p.codigoEntrega,
      lineas: [
        for (final d in p.detallePedidos_on_pedido)
          LineaTicket(d.cantidad, d.producto.nombre, d.precioEnElMomento),
      ],
    );
  }

  @override
  Future<void> subirComprobante(
      String pedidoId, Uint8List bytes, String tipo) async {
    final functions =
        _functions ?? FirebaseFunctions.instanceFor(region: 'us-east4');
    try {
      await functions.httpsCallable('subirComprobantePago').call({
        'pedidoId': pedidoId,
        'imagenBase64': base64Encode(bytes),
        'tipo': tipo,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'No se pudo subir el comprobante.');
    }
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
