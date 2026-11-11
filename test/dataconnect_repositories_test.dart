import 'package:agilu/data/models/item_carrito.dart';
import 'package:agilu/data/models/pedido.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/repositories/dataconnect_menu_repository.dart';
import 'package:agilu/data/repositories/dataconnect_pedido_repository.dart';
import 'package:agilu/dataconnect_generated/agilu.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('convierte un producto de SQL Connect al modelo de la app', () {
    final p = DataConnectMenuRepository.aProducto(ListarMenuProductos.fromJson(const {
      'id': 'b0000000000040008000000000000002',
      'nombre': 'Molletes',
      'descripcion': null,
      'precio': 40,
      'categoria': 'Desayunos',
      'disponible': false,
      'puesto': {'id': 'a0000000000040008000000000000001', 'nombre': 'Central'},
    }));
    expect(p.id, 'b0000000000040008000000000000002');
    expect(p.descripcion, '');
    expect(p.precio, 40.0);
    expect(p.disponible, isFalse);
    expect(p.cafeteriaId, 'a0000000000040008000000000000001');
  });

  test('el pedido solo manda producto y cantidad, nunca el precio', () {
    const molletes = Producto(
        id: 'm1', nombre: 'Molletes', descripcion: '', precio: 40, categoria: 'D');
    final pedido = Pedido(
      usuarioId: 'u1',
      cafeteriaId: 'c1',
      items: [ItemCarrito(producto: molletes, cantidad: 3)],
      total: 120,
      recogerA: DateTime(2026, 11, 5, 13),
    );
    expect(DataConnectPedidoRepository.itemsDe(pedido), [
      {'productoId': 'm1', 'cantidad': 3},
    ]);
  });
}
