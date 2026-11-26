import 'package:agilu/data/models/pedido_panel.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/models/ticket.dart';
import 'package:agilu/ui/cart/cart_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

Producto _p(String id,
        {bool disponible = true,
        bool controlar = false,
        int existencias = 0,
        String cafeteria = 'c1'}) =>
    Producto(
        id: id,
        nombre: id,
        descripcion: '',
        precio: 10,
        categoria: 'C',
        disponible: disponible,
        cafeteriaId: cafeteria,
        controlarStock: controlar,
        existencias: existencias);

void main() {
  group('volver a pedir', () {
    test('agrega lo que sigue a la venta y avisa lo que no', () {
      final vm = CartViewModel();
      final faltan = vm.volverAPedir(const [
        LineaReorden('torta', 'Torta', 2),
        LineaReorden('flan', 'Flan', 1),
        LineaReorden('agua', 'Agua', 3),
      ], [
        _p('torta'),
        _p('flan', disponible: false),
        _p('agua', controlar: true, existencias: 1),
      ]);
      expect(vm.items.map((i) => '${i.producto.id}x${i.cantidad}'),
          ['tortax2', 'aguax1']);
      expect(faltan, ['Flan', 'Agua']);
    });

    test('un producto que ya no existe no se agrega', () {
      final vm = CartViewModel();
      final faltan = vm.volverAPedir(
          const [LineaReorden('viejo', 'Producto viejo', 1)], [_p('torta')]);
      expect(vm.vacio, isTrue);
      expect(faltan, ['Producto viejo']);
    });

    test('no mezcla cafeterías en el carrito', () {
      final vm = CartViewModel()..agregar(_p('cafe', cafeteria: 'c2'));
      final faltan = vm.volverAPedir(
          const [LineaReorden('torta', 'Torta', 1)], [_p('torta')]);
      expect(faltan, ['Torta']);
      expect(vm.error, contains('otra cafetería'));
      expect(vm.items.single.producto.id, 'cafe');
    });

    test('solo los pedidos terminados se pueden repetir', () {
      ResumenPedido r(EstadoPedido e) => ResumenPedido(
          id: 'p',
          folio: 'AGU-00001',
          estado: e,
          recogerA: DateTime(2026, 11, 26),
          total: 10,
          cafeteria: 'Central',
          lineas: const [LineaReorden('torta', 'Torta', 1)]);
      expect(r(EstadoPedido.entregado).sePuedeRepetir, isTrue);
      expect(r(EstadoPedido.cancelado).sePuedeRepetir, isTrue);
      expect(r(EstadoPedido.preparando).sePuedeRepetir, isFalse);
    });
  });

  test('el panel dice cuánto tiempo lleva el pedido', () {
    final ahora = DateTime(2026, 11, 26, 12, 30);
    PedidoPanel p(DateTime? creado) => PedidoPanel(
        id: 'p',
        folio: 1,
        estado: EstadoPedido.pendiente,
        recogerA: ahora,
        alumno: 'Ana',
        creadoEn: creado);
    expect(p(ahora.subtract(const Duration(seconds: 20))).transcurrido(ahora),
        'hace menos de 1 min');
    expect(p(ahora.subtract(const Duration(minutes: 7))).transcurrido(ahora),
        'hace 7 min');
    expect(p(ahora.subtract(const Duration(minutes: 80))).transcurrido(ahora),
        'hace 1 h 20 min');
    expect(p(ahora.subtract(const Duration(hours: 2))).transcurrido(ahora),
        'hace 2 h');
    expect(p(null).transcurrido(ahora), isNull);
  });
}
