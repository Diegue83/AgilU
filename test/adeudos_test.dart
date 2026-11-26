import 'package:agilu/data/models/cafeteria.dart';
import 'package:agilu/data/models/confianza.dart';
import 'package:agilu/data/models/pedido_panel.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/models/ticket.dart';
import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/pagos_repository.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/ui/cart/cart_view_model.dart';
import 'package:agilu/ui/encargado/pagos/pagos_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _central = Cafeteria(
  id: 'c1',
  nombre: 'Central',
  aperturaMinutos: 8 * 60,
  cierreMinutos: 14 * 60,
  anticipacionMinutos: 30,
  intervaloMinutos: 30,
  capacidadPorFranja: 5,
);
const _torta = Producto(
    id: 't',
    nombre: 'Torta',
    descripcion: '',
    precio: 50,
    categoria: 'C',
    cafeteriaId: 'c1');

Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  final ahora = DateTime(2026, 11, 10, 10, 10);

  CartViewModel carrito() {
    final vm = CartViewModel(ahora: () => ahora)..configurarCafeteria(_central);
    vm.agregar(_torta);
    vm.elegirHora(DateTime(2026, 11, 10, 12));
    return vm;
  }

  Future<AuthRepository> sesion() async {
    final auth = MockAuthRepository();
    await auth.iniciarSesion('a@utng.edu.mx', '123456');
    return auth;
  }

  group('confianza', () {
    test('se lee del servidor y con 100 permite pagar al recoger', () {
      final c = Confianza.desdeMapa(const {
        'puntos': 100,
        'noRecogidos': 0,
        'adeudo': 0,
        'creditosAbiertos': 0,
      });
      expect(c.puedePagarAlRecoger, isTrue);
      expect(
          Confianza.desdeMapa(const {'puntos': 80, 'noRecogidos': 1})
              .puedePagarAlRecoger,
          isFalse);
      expect(
          const Confianza(puntos: 100, adeudo: 50, creditosAbiertos: 1)
              .puedePagarAlRecoger,
          isFalse);
      expect(Confianza.desdeMapa(null).puntos, 100);
    });
  });

  group('pagar al recoger', () {
    test('con 100 de confianza el pedido entra a cocina y cuenta como adeudo',
        () async {
      final repo = MockPedidoRepository();
      final vm = carrito();
      await vm.cargarConfianza(repo);
      expect(vm.puedePagarAlRecoger, isTrue);
      vm.elegirPagoAlRecoger(true);
      final r = await vm.confirmar(await sesion(), repo);

      final t = (await repo.ticket(r!.id))!;
      expect(t.estado, EstadoPedido.pendiente);
      expect(t.alRecoger, isTrue);
      expect(t.debe, isTrue);
      expect(t.pagado, isFalse);
      expect(t.muestraCodigo, isTrue);
      expect(t.etiquetaEstado, 'Pagas al recoger');
      expect(vm.pagoAlRecoger, isFalse);

      final c = await repo.confianza();
      expect(c.adeudo, 50);
      expect(c.puedePagarAlRecoger, isFalse);

      // El siguiente carrito ya no ofrece pagar al recoger.
      final otro = carrito();
      await otro.cargarConfianza(repo);
      otro.elegirPagoAlRecoger(true);
      expect(otro.pagoAlRecoger, isFalse);
    });

    test('con menos de 100 no se puede elegir', () async {
      final repo = MockPedidoRepository()..sinRecoger = 1;
      expect((await repo.confianza()).puntos, 80);
      final vm = carrito();
      await vm.cargarConfianza(repo);
      vm.elegirPagoAlRecoger(true);
      expect(vm.pagoAlRecoger, isFalse);
      final r = await vm.confirmar(await sesion(), repo);
      expect((await repo.ticket(r!.id))!.estado, EstadoPedido.porPagar);
    });

    test('un pedido pagado por transferencia no es adeudo', () {
      final t = TicketPedido(
        id: 'p',
        folio: 'AGU-00001',
        referencia: 'AGU-00001',
        estado: EstadoPedido.pendiente,
        recogerA: ahora,
        total: 50,
        cafeteria: 'Central',
      );
      expect(t.debe, isFalse);
      expect(t.pagado, isTrue);
      expect(t.etiquetaEstado, 'Pagado');
    });

    test('si no se recoge sigue debiéndose hasta que se paga', () {
      TicketPedido con({DateTime? pagadoEn}) => TicketPedido(
            id: 'p',
            folio: 'AGU-00001',
            referencia: 'AGU-00001',
            estado: EstadoPedido.noRecogido,
            recogerA: ahora,
            total: 50,
            cafeteria: 'Central',
            alRecoger: true,
            pagadoEn: pagadoEn,
          );
      expect(con().debe, isTrue);
      expect(con(pagadoEn: ahora).debe, isFalse);
    });
  });

  test('el encargado cobra un adeudo y sale de la lista', () async {
    final repo = MockPagosRepository()
      ..pendientes.add(AdeudoPorCobrar(
          pedidoId: 'p1',
          folio: 'AGU-00001',
          total: 50,
          recogerA: ahora,
          alumno: 'Ana'));
    final vm = PagosViewModel(repo);
    await _esperar();
    expect(vm.adeudos, hasLength(1));
    expect(await vm.cobrar(vm.adeudos.first), isTrue);
    expect(vm.adeudos, isEmpty);
    expect(
        await vm.cobrar(AdeudoPorCobrar(
            pedidoId: 'p1',
            folio: 'AGU-00001',
            total: 50,
            recogerA: ahora,
            alumno: 'Ana')),
        isFalse);
  });
}
