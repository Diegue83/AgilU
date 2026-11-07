import 'package:agilu/data/models/cafeteria.dart';
import 'package:agilu/data/models/pedido.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/cafeteria_repository.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/ui/cart/cart_view_model.dart';
import 'package:agilu/ui/encargado/cafeteria/cafeteria_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _central = Cafeteria(
  id: 'c1',
  nombre: 'Central',
  aperturaMinutos: 8 * 60,
  cierreMinutos: 14 * 60,
  anticipacionMinutos: 30,
  intervaloMinutos: 30,
  capacidadPorFranja: 2,
);
const _torta = Producto(
    id: 't',
    nombre: 'Torta',
    descripcion: '',
    precio: 50,
    categoria: 'C',
    cafeteriaId: 'c1');

class _Rechaza extends MockPedidoRepository {
  @override
  Future<PedidoCreado> crearPedido(Pedido pedido) async =>
      throw const PedidoRechazado('Esa hora ya se llenó. Elige otra.');
}

void main() {
  final ahora = DateTime(2026, 11, 10, 10, 10);

  CartViewModel carrito() {
    final vm = CartViewModel(ahora: () => ahora)..configurarCafeteria(_central);
    vm.agregar(_torta);
    return vm;
  }

  test('las horas siguen el horario, intervalo y anticipación de la cafetería',
      () {
    final horas = carrito().horasDisponibles;
    expect(horas.first, DateTime(2026, 11, 10, 11));
    expect(horas.last, DateTime(2026, 11, 10, 14));
    expect(horas.every((h) => h.minute % 30 == 0), isTrue);
  });

  test('una franja con la capacidad cubierta aparece llena y no se puede usar',
      () async {
    final once = DateTime(2026, 11, 10, 11);
    final vm = carrito();
    await vm.cargarOcupacion(MockPedidoRepository(ocupadas: {once: 2}));
    final validas = vm.franjas.where((f) => !f.muyPronto).toList();
    expect(validas.first.hora, once);
    expect(validas.first.llena, isTrue);
    expect(validas[1].llena, isFalse);
    vm.elegirHora(once);
    expect(vm.validar(), 'Esa hora ya se llenó. Elige otra.');
  });

  test(
      'si el servidor rechaza el pedido se muestra su motivo y no se vacía el carrito',
      () async {
    final vm = carrito()..elegirHora(DateTime(2026, 11, 10, 12));
    final auth = MockAuthRepository();
    await auth.iniciarSesion('a@utng.edu.mx', '123456');
    final r = await vm.confirmar(auth, _Rechaza());
    expect(r, isNull);
    expect(vm.error, 'Esa hora ya se llenó. Elige otra.');
    expect(vm.vacio, isFalse);
  });

  test('un pedido aceptado genera folio y ocupa su franja', () async {
    final repo = MockPedidoRepository();
    final vm = carrito()..elegirHora(DateTime(2026, 11, 10, 12));
    final auth = MockAuthRepository();
    await auth.iniciarSesion('a@utng.edu.mx', '123456');
    final r = await vm.confirmar(auth, repo);
    expect(r!.folio, 'AGU-00001');
    expect((await repo.ocupacion('c1'))[DateTime(2026, 11, 10, 12)], 1);
  });

  group('ajustes de la cafetería', () {
    test('valida horario, anticipación, intervalo y capacidad', () {
      expect(_central.copiar(cierreMinutos: 7 * 60).validar(),
          'La hora de cierre debe ser después de la apertura.');
      expect(_central.copiar(anticipacionMinutos: 300).validar(),
          'La anticipación debe estar entre 0 y 240 minutos.');
      expect(_central.copiar(intervaloMinutos: 2).validar(),
          'El intervalo debe estar entre 5 y 60 minutos.');
      expect(_central.copiar(capacidadPorFranja: 0).validar(),
          'La capacidad debe estar entre 1 y 200 pedidos.');
      expect(_central.validar(), isNull);
    });

    test('guarda los ajustes válidos', () async {
      final repo = MockCafeteriaRepository();
      final vm = CafeteriaViewModel(repo);
      await vm.cargar();
      vm.cambiar(vm.cafeteria!.copiar(capacidadPorFranja: 8));
      expect(await vm.guardar(), isTrue);
      expect(repo.cafeteria.capacidadPorFranja, 8);
    });
  });
}
