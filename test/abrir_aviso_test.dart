import 'package:agilu/data/repositories/avisos_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('los avisos del alumno abren el ticket y los del personal el panel', () {
    AvisoAbierto a(Map<String, dynamic> d) => AvisoAbierto.desdeDatos(d);
    expect(a({'evento': 'pedido_listo', 'pedidoId': 'p1'}).destino,
        DestinoAviso.ticket);
    expect(a({'evento': 'pago_validado', 'pedidoId': 'p1'}).destino,
        DestinoAviso.ticket);
    expect(a({'evento': 'pago_rechazado', 'pedidoId': 'p1'}).destino,
        DestinoAviso.ticket);
    // Las versiones anteriores mandaban "tipo".
    expect(a({'tipo': 'pedido_listo', 'pedidoId': 'p1'}).destino,
        DestinoAviso.ticket);
    expect(a({'evento': 'comprobante', 'pedidoId': 'p1'}).destino,
        DestinoAviso.panel);
    expect(a({'evento': 'solicitud'}).destino, DestinoAviso.panel);
    expect(a({'evento': 'pedido_listo'}).destino, DestinoAviso.ninguno);
    expect(a({}).destino, DestinoAviso.ninguno);
  });
}
