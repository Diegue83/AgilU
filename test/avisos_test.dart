import 'dart:typed_data';

import 'package:agilu/data/models/item_carrito.dart';
import 'package:agilu/data/models/pedido.dart';
import 'package:agilu/data/models/pedido_panel.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/contadores_repository.dart';
import 'package:agilu/data/repositories/notificador.dart';
import 'package:agilu/data/repositories/pagos_repository.dart';
import 'package:agilu/data/repositories/panel_repository.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/data/repositories/perfil_repository.dart';
import 'package:agilu/ui/auth/registro_view_model.dart';
import 'package:agilu/ui/comun/contadores.dart';
import 'package:agilu/ui/encargado/pagos/pagos_view_model.dart';
import 'package:agilu/ui/encargado/panel/panel_view_model.dart';
import 'package:agilu/ui/pedido/ticket_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  group('cada acción pide su aviso', () {
    test('subir el comprobante avisa al encargado', () async {
      final repo = MockPedidoRepository();
      final r = await repo.crearPedido(Pedido(
        usuarioId: 'u',
        cafeteriaId: 'c1',
        items: [
          ItemCarrito(
              producto: const Producto(
                  id: 't',
                  nombre: 'Torta',
                  descripcion: '',
                  precio: 50,
                  categoria: 'C'))
        ],
        total: 50,
        recogerA: DateTime(2026, 11, 12, 13),
      ));
      final avisos = MockNotificador();
      final vm = TicketViewModel(repo, r.id, avisos: avisos);
      await vm.cargar();
      await vm.subirComprobante(
          Uint8List.fromList([0xff, 0xd8, 0xff]), 'image/jpeg');
      expect(avisos.enviados, [(EventoAviso.comprobante, r.id)]);
    });

    test('validar o rechazar el pago avisa al alumno', () async {
      final repo = MockPagosRepository();
      final avisos = MockNotificador();
      final vm = PagosViewModel(repo, avisos: avisos);
      await _esperar();
      final p = vm.pagos.single;
      await vm.aprobar(p);
      expect(avisos.enviados, [(EventoAviso.pagoValidado, p.pedidoId)]);

      final repo2 = MockPagosRepository();
      final avisos2 = MockNotificador();
      final vm2 = PagosViewModel(repo2, avisos: avisos2);
      await _esperar();
      await vm2.rechazar(vm2.pagos.single, 'Monto incompleto');
      expect(avisos2.enviados.single.$1, EventoAviso.pagoRechazado);
    });

    test('solo marcar listo avisa; preparar no', () async {
      final avisos = MockNotificador();
      final vm = PanelViewModel(MockPanelRepository(), avisos: avisos);
      await _esperar();
      await vm.avanzar(vm.enEstado(EstadoPedido.pendiente).first);
      expect(avisos.enviados, isEmpty);
      final preparando = vm.enEstado(EstadoPedido.preparando).first;
      await vm.avanzar(preparando);
      expect(avisos.enviados, [(EventoAviso.pedidoListo, preparando.id)]);
      vm.dispose();
    });

    test('solicitar trabajo avisa al encargado; registrarse como alumno no',
        () async {
      final avisos = MockNotificador();
      final emp = RegistroViewModel(MockAuthRepository(),
          perfiles: MockPerfilRepository(), empleado: true, avisos: avisos);
      await _esperar();
      emp.elegirCafeteria('c1');
      emp.continuar('Rosa', 'Medina', '');
      await emp.registrar('rosa@correo.com', '123456', '123456');
      expect(avisos.enviados, [(EventoAviso.solicitud, null)]);

      final avisos2 = MockNotificador();
      final alumno = RegistroViewModel(MockAuthRepository(),
          perfiles: MockPerfilRepository(), avisos: avisos2);
      alumno.continuar('Ana', 'López', '');
      await alumno.registrar('ana@utng.edu.mx', '123456', '123456');
      expect(avisos2.enviados, isEmpty);
    });
  });

  group('puntos rojos', () {
    test('los conteos se leen de la fila del servidor', () {
      final c = Contadores.desdeMapa({
        'pagos': 2,
        'enEspera': 1,
        'solicitudes': 3,
        'listos': 0,
        'avisos': 5
      });
      expect([c.pagos, c.enEspera, c.solicitudes, c.listos, c.avisos],
          [2, 1, 3, 0, 5]);
      expect(Contadores.desdeMapa(const {}).avisos, 0);
    });

    test('el controlador consulta al activarse y deja de hacerlo al cerrar',
        () async {
      final repo =
          MockContadoresRepository(contadores: const Contadores(pagos: 1));
      final c = ContadoresController(repo,
          intervalo: const Duration(milliseconds: 10));
      c.activar();
      await _esperar();
      expect(c.actual.pagos, 1);
      repo.contadores = const Contadores(pagos: 4);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(c.actual.pagos, 4);
      c.desactivar();
      repo.contadores = const Contadores(pagos: 9);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(c.actual.pagos, 4);
      c.dispose();
    });
  });
}
