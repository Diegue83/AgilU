import 'dart:async';

import 'package:agilu/data/models/cafeteria.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/repositories/menu_repository.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/ui/menu/menu_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _Menu implements MenuRepository {
  final List<Producto> productos;
  final List<Cafeteria> lista;
  _Menu(this.productos, this.lista);

  @override
  Stream<List<Producto>> observarMenu() => Stream.value(productos);

  @override
  Future<List<Cafeteria>> cafeterias() async => lista;
}

const _central = Cafeteria(
    id: 'c1',
    nombre: 'Central',
    aperturaMinutos: 7 * 60 + 30,
    cierreMinutos: 15 * 60);
const _barra = Cafeteria(id: 'c2', nombre: 'Barra');

Producto _p(String id, String nombre,
        {String cafeteria = 'c1', bool disponible = true, int orden = 1}) =>
    Producto(
        id: id,
        nombre: nombre,
        descripcion: '',
        precio: 10,
        categoria: 'X',
        disponible: disponible,
        cafeteriaId: cafeteria,
        estacion: 'E$orden',
        estacionOrden: orden);

Future<MenuViewModel> _vm(List<Producto> productos,
    {List<Cafeteria> cafeterias = const [_central, _barra],
    DateTime? ahora}) async {
  final vm = MenuViewModel(_Menu(productos, cafeterias),
      ahora: () => ahora ?? DateTime(2026, 11, 10, 10));
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  return vm;
}

void main() {
  test('muestra solo la cafetería elegida, con lo agotado al final', () async {
    final vm = await _vm([
      _p('1', 'Agotado', disponible: false),
      _p('2', 'Torta'),
      _p('3', 'Capuchino', cafeteria: 'c2'),
    ]);
    expect(vm.cargando, isFalse);
    expect(vm.productosVisibles.map((p) => p.nombre), ['Torta', 'Agotado']);
    vm.seleccionarCafeteria('c2');
    expect(vm.productosVisibles.map((p) => p.nombre), ['Capuchino']);
  });

  test('en horario normal no hay aviso y se puede pedir', () async {
    final vm = await _vm([_p('1', 'Torta')]);
    expect(vm.aviso, isNull);
    expect(vm.puedePedir, isTrue);
  });

  test('antes de abrir avisa la hora pero deja programar', () async {
    final vm = await _vm([_p('1', 'Torta')], ahora: DateTime(2026, 11, 10, 6));
    expect(
        vm.aviso, 'Central abre a las 07:30. Ya puedes programar tu pedido.');
    expect(vm.puedePedir, isTrue);
  });

  test('cuando ya no da tiempo antes del cierre la app lo dice', () async {
    final vm =
        await _vm([_p('1', 'Torta')], ahora: DateTime(2026, 11, 10, 14, 30));
    expect(
        vm.aviso, 'Central ya no recibe pedidos hoy. Abre mañana a las 07:30.');
    expect(vm.puedePedir, isFalse);
  });

  test('sin productos avisa que no hay menú cargado', () async {
    final vm = await _vm([_p('3', 'Capuchino', cafeteria: 'c2')]);
    expect(vm.aviso, 'Hoy no hay menú cargado en Central.');
    expect(vm.puedePedir, isFalse);
  });

  test('si todo está agotado lo dice', () async {
    final vm = await _vm([_p('1', 'Torta', disponible: false)]);
    expect(vm.aviso, 'Todo el menú de hoy está agotado en Central.');
  });

  test('sin cafeterías activas lo dice', () async {
    final vm = await _vm([], cafeterias: const []);
    expect(vm.aviso, 'Por ahora no hay cafeterías abiertas.');
    expect(vm.puedePedir, isFalse);
  });

  group('sistema de confianza', () {
    Future<MenuViewModel> conNoRecogidos(int n) async {
      final pedidos = MockPedidoRepository()..sinRecoger = n;
      final vm = MenuViewModel(_Menu([_p('1', 'Torta')], const [_central]),
          ahora: () => DateTime(2026, 11, 10, 10), pedidos: pedidos);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      return vm;
    }

    test('sin pedidos no recogidos no hay aviso', () async {
      final vm = await conNoRecogidos(0);
      expect(vm.avisoConfianza, isNull);
      expect(vm.puedePedir, isTrue);
    });

    test('con uno o dos avisa antes del bloqueo', () async {
      final vm = await conNoRecogidos(2);
      expect(vm.avisoConfianza, startsWith('Tienes 2 pedido(s) sin recoger'));
      expect(vm.puedePedir, isTrue);
    });

    test('con 3 bloquea los pedidos nuevos', () async {
      final vm = await conNoRecogidos(3);
      expect(vm.bloqueadoPorConfianza, isTrue);
      expect(vm.puedePedir, isFalse);
    });
  });
}
