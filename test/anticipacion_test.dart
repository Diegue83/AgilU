import 'package:agilu/data/models/cafeteria.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/ui/cart/cart_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _central = Cafeteria(
  id: 'c1',
  nombre: 'Central',
  aperturaMinutos: 8 * 60,
  cierreMinutos: 14 * 60,
  anticipacionMinutos: 60,
  intervaloMinutos: 30,
);
const _torta = Producto(
    id: 't',
    nombre: 'Torta',
    descripcion: '',
    precio: 50,
    categoria: 'C',
    cafeteriaId: 'c1');
const _agua = Producto(
    id: 'a',
    nombre: 'Agua',
    descripcion: '',
    precio: 15,
    categoria: 'B',
    cafeteriaId: 'c1',
    preparacionInmediata: true);

void main() {
  final ahora = DateTime(2026, 11, 10, 10, 10);

  CartViewModel carrito(Cafeteria c, List<Producto> productos) {
    final vm = CartViewModel(ahora: () => ahora)..configurarCafeteria(c);
    for (final p in productos) {
      vm.agregar(p);
    }
    return vm;
  }

  test('las horas con menos de la anticipación se muestran deshabilitadas', () {
    final f = carrito(_central, [_torta]).franjas;
    final cercanas = f.where((x) => x.muyPronto).map((x) => x.hora).toList();
    expect(
        cercanas, [DateTime(2026, 11, 10, 10, 30), DateTime(2026, 11, 10, 11)]);
    expect(
        f.firstWhere((x) => x.elegible).hora, DateTime(2026, 11, 10, 11, 30));
  });

  test('elegir una hora muy cercana muestra el aviso de la anticipación', () {
    final vm = carrito(_central, [_torta])
      ..elegirHora(DateTime(2026, 11, 10, 10, 30));
    expect(vm.validar(),
        'Los pedidos requieren 60 minutos de anticipación. Elige otra hora.');
  });

  test(
      'si la cocina lo permite, un pedido solo de inmediatos no pide anticipación',
      () {
    final c = _central.copiar(permitirInmediatos: true);
    final vm = carrito(c, [_agua]);
    expect(vm.anticipacionMinutos, 0);
    expect(vm.franjas.first.elegible, isTrue);
    expect(vm.franjas.first.hora, DateTime(2026, 11, 10, 10, 30));
  });

  test('con un platillo en el pedido vuelve a aplicar la anticipación', () {
    final c = _central.copiar(permitirInmediatos: true);
    expect(carrito(c, [_agua, _torta]).anticipacionMinutos, 60);
  });

  test('sin la opción de la cocina, ni los inmediatos se libran', () {
    expect(carrito(_central, [_agua]).anticipacionMinutos, 60);
  });
}
