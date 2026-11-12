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
import 'almacen_archivos.dart';
import 'pedido_repository.dart';

/// Envía el pedido con la operación CrearPedido. El servidor toma los precios
/// del catálogo, calcula el total y asigna el folio; aquí solo se manda qué
/// productos y cuántos.
class DataConnectPedidoRepository implements PedidoRepository {
  final AgiluConnector _conector;
  final Random _azar;
  final FirebaseFunctions? _functions;

  /// Con Supabase, el comprobante se sube al bucket privado "comprobantes" y se
  /// liga al pedido con EnviarComprobante. Sin él, se usa la Cloud Function.
  final AlmacenArchivos? _almacen;
  final String? Function()? _uid;

  DataConnectPedidoRepository(
      {AgiluConnector? conector,
      Random? azar,
      FirebaseFunctions? functions,
      AlmacenArchivos? almacen,
      String? Function()? uid})
      : _conector = conector ?? conectorAgilu,
        _azar = azar ?? Random.secure(),
        _functions = functions,
        _almacen = almacen,
        _uid = uid;

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
    return noRecogidosDe(res.data);
  }

  // Las operaciones de SQL nativo regresan AnyValue: el mapa o la lista
  // están en .value.
  static int noRecogidosDe(MiConfianzaData d) =>
      ((d.confianza?.value as Map?)?['noRecogidos'] as num?)?.toInt() ?? 0;

  static String? motivoDe(DiagnosticarPedidoData d) {
    final motivo = (d.diagnostico?.value as Map?)?['motivo'];
    return motivo is String && motivo.isNotEmpty ? motivo : null;
  }

  static Map<DateTime, int> ocupacionDe(OcupacionFranjasData d) => {
        for (final f
            in (d.franjas ?? const <AnyValue>[]).map((v) => v.value as Map))
          DateTime.parse(f['recogerA'] as String).toLocal():
              (f['pedidos'] as num).toInt(),
      };

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
  Future<bool> cancelar(String pedidoId) async {
    final res = await _conector.cancelarMiPedido(id: pedidoId).execute();
    final fila = res.data.resultado?.value as Map?;
    if (fila == null) throw const PedidoRechazado(motivoNoCancelable);
    return fila['pagado'] == true;
  }

  @override
  Future<void> subirComprobante(
      String pedidoId, Uint8List bytes, String tipo) async {
    final almacen = _almacen;
    if (almacen != null) return _subirASupabase(almacen, pedidoId, bytes, tipo);
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

  Future<void> _subirASupabase(AlmacenArchivos almacen, String pedidoId,
      Uint8List bytes, String tipo) async {
    final problema = validarImagen(bytes, tipo);
    if (problema != null) throw Exception(problema);
    final uid = _uid?.call();
    if (uid == null) throw Exception('Inicia sesión de nuevo.');
    final ruta = rutaArchivo(uid, pedidoId, tipo);
    try {
      await almacen.subir('comprobantes', ruta, bytes, tipo);
    } catch (_) {
      throw Exception('No se pudo subir el comprobante.');
    }
    final res = await _conector
        .enviarComprobante(pedidoId: pedidoId, ruta: ruta)
        .execute();
    if (res.data.resultado == null) {
      throw Exception('Este pedido ya no espera comprobante.');
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
      final motivo = motivoDe(d.data);
      if (motivo != null) return motivo;
    } catch (_) {
      // Si tampoco se puede diagnosticar, se usa el mensaje general.
    }
    return 'La cafetería rechazó el pedido. Revisa tu carrito e intenta de nuevo.';
  }

  @override
  Future<Map<DateTime, int>> ocupacion(String cafeteriaId) async {
    final res =
        await _conector.ocupacionFranjas(cafeteriaId: cafeteriaId).execute();
    return ocupacionDe(res.data);
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
