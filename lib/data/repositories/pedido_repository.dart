import 'dart:typed_data';

import '../../core/reglas_pedido.dart';
import '../models/confianza.dart';
import '../models/pedido.dart';
import '../models/pedido_panel.dart';
import '../models/ticket.dart';

/// El servidor no aceptó el pedido; [motivo] se muestra al alumno.
class PedidoRechazado implements Exception {
  final String motivo;
  const PedidoRechazado(this.motivo);

  @override
  String toString() => motivo;
}

abstract class PedidoRepository {
  /// Envía el pedido. Si el servidor lo rechaza, lanza [PedidoRechazado].
  Future<PedidoCreado> crearPedido(Pedido pedido);

  /// Pedidos por hora de recogida de hoy en la cafetería.
  Future<Map<DateTime, int>> ocupacion(String cafeteriaId);

  Future<List<ResumenPedido>> misPedidos();
  Future<TicketPedido?> ticket(String id);

  /// HU-23: pedidos que el alumno no recogió en los últimos 30 días.
  Future<int> noRecogidos();

  /// HU-23: confianza de 0 a 100, adeudo y si puede pagar al recoger.
  Future<Confianza> confianza();

  /// HU-08: sube el comprobante de la transferencia.
  Future<void> subirComprobante(String pedidoId, Uint8List bytes, String tipo);

  /// Cancela el pedido del alumno. Devuelve true si ya estaba pagado (toca
  /// reembolso). Si ya se empezó a preparar lanza [PedidoRechazado].
  Future<bool> cancelar(String pedidoId);
}

const motivoNoCancelable =
    'Ya no se puede cancelar: la cocina empezó a preparar tu pedido.';

class MockPedidoRepository implements PedidoRepository {
  int _contador = 0;
  final Map<DateTime, int> ocupadas;
  final Map<String, TicketPedido> tickets = {};
  MockPedidoRepository({Map<DateTime, int>? ocupadas})
      : ocupadas = ocupadas ?? {};

  @override
  Future<PedidoCreado> crearPedido(Pedido pedido) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _contador++;
    ocupadas.update(pedido.recogerA, (n) => n + 1, ifAbsent: () => 1);
    final folio = ReglasPedido.formatearFolio(_contador);
    final id = 'p$_contador';
    tickets[id] = TicketPedido(
      id: id,
      folio: folio,
      referencia: folio,
      estado:
          pedido.pagoAlRecoger ? EstadoPedido.pendiente : EstadoPedido.porPagar,
      alRecoger: pedido.pagoAlRecoger,
      codigoEntrega: pedido.pagoAlRecoger ? '1234' : null,
      recogerA: pedido.recogerA,
      total: pedido.total,
      cafeteria: 'Cafetería central',
      banco: 'Banco Ejemplo',
      clabe: '000000000000000000',
      titular: 'Cafetería Central (datos de prueba)',
      lineas: [
        for (final i in pedido.items)
          LineaTicket(i.cantidad, i.producto.nombre, i.precioUnitario),
      ],
    );
    return PedidoCreado(id, folio);
  }

  @override
  Future<Map<DateTime, int>> ocupacion(String cafeteriaId) async =>
      Map.of(ocupadas);

  @override
  Future<List<ResumenPedido>> misPedidos() async => [
        for (final t in tickets.values)
          ResumenPedido(
            id: t.id,
            folio: t.folio,
            estado: t.estado,
            recogerA: t.recogerA,
            total: t.total,
            cafeteria: t.cafeteria,
          ),
      ];

  @override
  Future<TicketPedido?> ticket(String id) async => tickets[id];

  int sinRecoger = 0;

  @override
  Future<int> noRecogidos() async => sinRecoger;

  @override
  Future<Confianza> confianza() async {
    final deudas = tickets.values.where((t) => t.debe);
    return Confianza(
      puntos: (100 - 20 * sinRecoger).clamp(0, 100),
      noRecogidos: sinRecoger,
      adeudo: deudas.fold(0.0, (s, t) => s + t.total),
      creditosAbiertos: deudas.length,
    );
  }

  @override
  Future<bool> cancelar(String pedidoId) async {
    final t = tickets[pedidoId];
    if (t == null || !t.sePuedeCancelar) {
      throw const PedidoRechazado(motivoNoCancelable);
    }
    tickets[pedidoId] = TicketPedido(
      id: t.id,
      folio: t.folio,
      referencia: t.referencia,
      estado: EstadoPedido.cancelado,
      recogerA: t.recogerA,
      total: t.total,
      cafeteria: t.cafeteria,
      pagadoEn: t.pagadoEn,
      lineas: t.lineas,
      alRecoger: t.alRecoger,
    );
    return t.pagado;
  }

  @override
  Future<void> subirComprobante(
      String pedidoId, Uint8List bytes, String tipo) async {
    final t = tickets[pedidoId]!;
    tickets[pedidoId] = TicketPedido(
      id: t.id,
      folio: t.folio,
      referencia: t.referencia,
      estado: EstadoPedido.pagoEnRevision,
      recogerA: t.recogerA,
      total: t.total,
      cafeteria: t.cafeteria,
      banco: t.banco,
      clabe: t.clabe,
      titular: t.titular,
      lineas: t.lineas,
    );
  }
}
