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

  /// Se paga en la cafetería al recoger; cuenta como adeudo hasta pagarse.
  final bool alRecoger;

  /// Estación que prepara y cobra el pedido.
  final String? estacion;

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
    this.alRecoger = false,
    this.estacion,
  });

  /// Pasos que ve el alumno, de pagar a recoger.
  static const pasos = ['Pago', 'Recibido', 'Preparando', 'Listo', 'Entregado'];

  /// Paso en curso (índice de [pasos]), o null si el pedido se canceló o no
  /// se recogió.
  int? get pasoActual => switch (estado) {
        EstadoPedido.porPagar || EstadoPedido.pagoEnRevision => 0,
        EstadoPedido.pendiente => 1,
        EstadoPedido.preparando => 2,
        EstadoPedido.listo => 3,
        EstadoPedido.entregado => 4,
        EstadoPedido.cancelado || EstadoPedido.noRecogido => null,
      };

  /// El pedido ya no va a cambiar: no hace falta seguir actualizándolo.
  bool get terminado => const [
        EstadoPedido.entregado,
        EstadoPedido.cancelado,
        EstadoPedido.noRecogido,
      ].contains(estado);

  /// Pedido a pagar al recoger que todavía no se paga.
  bool get debe =>
      alRecoger && pagadoEn == null && estado != EstadoPedido.cancelado;

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
      !alRecoger &&
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
        EstadoPedido.listo when debe =>
          'Pagas al recoger',
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
  final String cafeteriaId;

  /// Productos y cantidades, para "Volver a pedir".
  final List<LineaReorden> lineas;

  const ResumenPedido({
    required this.id,
    required this.folio,
    required this.estado,
    required this.recogerA,
    required this.total,
    required this.cafeteria,
    this.cafeteriaId = '',
    this.lineas = const [],
  });

  /// Solo los pedidos que ya terminaron se vuelven a pedir.
  bool get sePuedeRepetir =>
      lineas.isNotEmpty &&
      const [
        EstadoPedido.entregado,
        EstadoPedido.cancelado,
        EstadoPedido.noRecogido,
      ].contains(estado);
}

/// Un producto de un pedido anterior.
class LineaReorden {
  final String productoId;
  final String nombre;
  final int cantidad;
  const LineaReorden(this.productoId, this.nombre, this.cantidad);
}

/// Comprobante que espera validación del encargado.
/// Pedido a pagar al recoger que no se recogió y sigue sin pagarse.
class AdeudoPorCobrar {
  final String pedidoId;
  final String folio;
  final double total;
  final DateTime recogerA;
  final String alumno;
  final String? estacion;
  const AdeudoPorCobrar({
    required this.pedidoId,
    required this.folio,
    required this.total,
    required this.recogerA,
    required this.alumno,
    this.estacion,
  });
}

class PagoPorValidar {
  final String pedidoId;
  final String folio;
  final String referencia;
  final double total;
  final DateTime recogerA;
  final String alumno;
  final String? comprobanteUrl;

  /// Estación que cobra el pedido.
  final String? estacion;
  const PagoPorValidar({
    required this.pedidoId,
    required this.folio,
    required this.referencia,
    required this.total,
    required this.recogerA,
    required this.alumno,
    this.comprobanteUrl,
    this.estacion,
  });
}
