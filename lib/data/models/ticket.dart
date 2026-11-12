import '../../core/reglas_pedido.dart';
import 'pedido_panel.dart';

class LineaTicket {
  final int cantidad;
  final String producto;
  final double precio;
  const LineaTicket(this.cantidad, this.producto, this.precio);

  double get subtotal => cantidad * precio;
}

/// Ticket del alumno (HU-22): instrucciones de pago mientras no se paga y
/// recibo con el estado "Pagado" cuando el encargado valida el comprobante.
class TicketPedido {
  final String id;
  final String folio;
  final String referencia;
  final EstadoPedido estado;
  final DateTime recogerA;
  final double total;
  final String? notas;
  final String cafeteria;
  final String? ubicacion;
  final String? banco;
  final String? clabe;
  final String? titular;
  final String? motivoRechazo;
  final DateTime? pagadoEn;
  final String? codigoEntrega;
  final List<LineaTicket> lineas;

  const TicketPedido({
    required this.id,
    required this.folio,
    required this.referencia,
    required this.estado,
    required this.recogerA,
    required this.total,
    required this.cafeteria,
    this.notas,
    this.ubicacion,
    this.banco,
    this.clabe,
    this.titular,
    this.motivoRechazo,
    this.pagadoEn,
    this.codigoEntrega,
    this.lineas = const [],
  });

  /// HU-09: el código se muestra mientras el pedido espera entregarse.
  bool get muestraCodigo =>
      codigoEntrega != null &&
      const [
        EstadoPedido.pendiente,
        EstadoPedido.preparando,
        EstadoPedido.listo,
      ].contains(estado);

  bool get pagado =>
      pagadoEn != null ||
      const [
        EstadoPedido.pendiente,
        EstadoPedido.preparando,
        EstadoPedido.listo,
        EstadoPedido.entregado,
      ].contains(estado);

  bool get esperaComprobante => estado == EstadoPedido.porPagar;

  /// El alumno puede cancelar mientras la cocina no empiece a prepararlo.
  bool get sePuedeCancelar => const [
        EstadoPedido.porPagar,
        EstadoPedido.pagoEnRevision,
        EstadoPedido.pendiente,
      ].contains(estado);

  /// Línea bajo el folio: cuándo y dónde recogerlo mientras sigue vigente; al
  /// final, cómo terminó.
  String get detalleRecogida {
    final hora = ReglasPedido.formatearHora(recogerA);
    final lugar = ubicacion == null ? cafeteria : '$cafeteria ($ubicacion)';
    return switch (estado) {
      EstadoPedido.cancelado =>
        'Pedido cancelado · era para las $hora en $lugar',
      EstadoPedido.noRecogido => 'No se recogió · era para las $hora en $lugar',
      EstadoPedido.entregado => 'Entregado en $lugar',
      _ => 'Recoge hoy a las $hora en $lugar',
    };
  }

  /// Etiqueta del ticket: mientras se prepara dice "Pagado"; al final, cómo
  /// terminó el pedido.
  String get etiquetaEstado => switch (estado) {
        EstadoPedido.pendiente ||
        EstadoPedido.preparando ||
        EstadoPedido.listo =>
          'Pagado',
        _ => estado.etiqueta,
      };
}

/// Pedido en la lista de "Mis pedidos".
class ResumenPedido {
  final String id;
  final String folio;
  final EstadoPedido estado;
  final DateTime recogerA;
  final double total;
  final String cafeteria;
  const ResumenPedido({
    required this.id,
    required this.folio,
    required this.estado,
    required this.recogerA,
    required this.total,
    required this.cafeteria,
  });
}

/// Comprobante que espera validación del encargado.
class PagoPorValidar {
  final String pedidoId;
  final String folio;
  final String referencia;
  final double total;
  final DateTime recogerA;
  final String alumno;
  final String? comprobanteUrl;
  const PagoPorValidar({
    required this.pedidoId,
    required this.folio,
    required this.referencia,
    required this.total,
    required this.recogerA,
    required this.alumno,
    this.comprobanteUrl,
  });
}
