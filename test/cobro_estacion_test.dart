import 'package:agilu/data/models/cafeteria.dart';
import 'package:agilu/data/models/pedido.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/estacion_repository.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/ui/cart/cart_view_model.dart';
import 'package:agilu/ui/encargado/estaciones/estaciones_view_model.dart';
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
Producto _p(String id, String estacion, double precio) => Producto(
    id: id,
    nombre: id,
    descripcion: '',
    precio: precio,
    categoria: 'C',
    cafeteriaId: 'c1',
    estacionId: 'e-$estacion',
    estacion: estacion);

class _Registra extends MockPedidoRepository {
  final List<Pedido> enviados = [];
  final String? rechazaEstacion;
  _Registra({this.rechazaEstacion});

  @override
  Future<PedidoCreado> crearPedido(Pedido pedido) async {
    if (pedido.items.any((i) => i.producto.estacion == rechazaEstacion)) {
      throw const PedidoRechazado('Algún producto ya no está disponible.');
    }
    enviados.add(pedido);
    return super.crearPedido(pedido);
  }
}

Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  final ahora = DateTime(2026, 11, 10, 10, 10);

  Future<AuthRepository> sesion() async {
    final auth = MockAuthRepository();
    await auth.iniciarSesion('a@utng.edu.mx', '123456');
    return auth;
  }

  CartViewModel carrito() {
    final vm = CartViewModel(ahora: () => ahora)..configurarCafeteria(_central);
    vm.agregar(_p('torta', 'Tortas', 50));
    vm.agregar(_p('torta', 'Tortas', 50));
    vm.agregar(_p('agua', 'Tiendita', 15));
    vm.elegirHora(DateTime(2026, 11, 10, 12));
    return vm;
  }

  test('un carrito con dos estaciones hace un pedido por estación', () async {
    final repo = _Registra();
    final vm = carrito();
    expect(vm.porEstacion.keys, ['Tortas', 'Tiendita']);
    final r = await vm.confirmar(await sesion(), repo);

    expect(repo.enviados, hasLength(2));
    expect(repo.enviados.map((p) => p.total), [100, 15]);
    expect(repo.enviados.map((p) => p.grupo).toSet(), hasLength(1));
    expect(repo.enviados.first.grupo, isNotNull);
    expect(r!.estacion, 'Tortas');
    expect(r.otros.single.estacion, 'Tiendita');
    expect(r.aviso, isNull);
    expect(vm.vacio, isTrue);
  });

  test('si una estación rechaza, sus productos se quedan en el carrito',
      () async {
    final repo = _Registra(rechazaEstacion: 'Tiendita');
    final vm = carrito();
    final r = await vm.confirmar(await sesion(), repo);

    expect(repo.enviados.single.items.single.producto.id, 'torta');
    expect(r!.otros, isEmpty);
    expect(r.aviso, contains('Tiendita'));
    expect(vm.items.single.producto.id, 'agua');
    expect(vm.recogerA, isNotNull);
  });

  test('si todas fallan no se crea nada y se explica', () async {
    final vm = CartViewModel(ahora: () => ahora)..configurarCafeteria(_central);
    vm.agregar(_p('agua', 'Tiendita', 15));
    vm.elegirHora(DateTime(2026, 11, 10, 12));
    final r = await vm.confirmar(
        await sesion(), _Registra(rechazaEstacion: 'Tiendita'));
    expect(r, isNull);
    expect(vm.error, 'Algún producto ya no está disponible.');
    expect(vm.vacio, isFalse);
  });

  test('la cuenta de cobro de una estación se valida', () async {
    final vm = EstacionesViewModel(MockEstacionRepository());
    await _esperar();
    expect(vm.validarCobro('', '', ''), isNull);
    expect(vm.validarCobro('Banco', '123', 'Tienda'),
        'La CLABE debe tener 18 dígitos.');
    expect(vm.validarCobro('', '012345678901234567', ''),
        'Escribe el banco y el titular de la cuenta.');
    final e = vm.estaciones.first;
    expect(
        await vm.editarCobro(e, 'Banco', '012345678901234567', 'Tortas UTNG'),
        isTrue);
    final guardada = vm.estaciones.firstWhere((x) => x.id == e.id);
    expect(guardada.tieneCuenta, isTrue);
    expect(guardada.titular, 'Tortas UTNG');
    expect(await vm.editarCobro(guardada, '', '', ''), isTrue);
    expect(vm.estaciones.firstWhere((x) => x.id == e.id).tieneCuenta, isFalse);
  });
}
