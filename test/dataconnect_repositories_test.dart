import 'package:agilu/data/models/item_carrito.dart';
import 'package:agilu/data/models/pedido.dart';
import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/repositories/dataconnect_menu_repository.dart';
import 'package:agilu/data/repositories/dataconnect_pedido_repository.dart';
import 'package:agilu/data/repositories/perfil_repository.dart';
import 'package:agilu/dataconnect_generated/agilu.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('convierte un producto de SQL Connect al modelo de la app', () {
    final p =
        DataConnectMenuRepository.aProducto(ListarMenuProductos.fromJson(const {
      'id': 'b0000000000040008000000000000002',
      'nombre': 'Molletes',
      'descripcion': null,
      'precio': 40,
      'categoria': 'Desayunos',
      'disponible': false,
      'puesto': {
        'id': 'a0000000000040008000000000000001',
        'nombre': 'Guisados',
        'orden': 1,
        'cafeteria': {
          'id': 'c0000000000040008000000000000001',
          'nombre': 'Central'
        },
      },
    }));
    expect(p.id, 'b0000000000040008000000000000002');
    expect(p.descripcion, '');
    expect(p.precio, 40.0);
    expect(p.disponible, isFalse);
    expect(p.cafeteriaId, 'c0000000000040008000000000000001');
    expect(p.estacionId, 'a0000000000040008000000000000001');
    expect(p.estacion, 'Guisados');
  });

  test('el pedido solo manda producto y cantidad, nunca el precio', () {
    const molletes = Producto(
        id: 'm1',
        nombre: 'Molletes',
        descripcion: '',
        precio: 40,
        categoria: 'D');
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

  test('un usuario sin rol es alumno', () {
    final p = DataConnectPerfilRepository.aPerfil(
        MiPerfilAutenticacion.fromJson(const {
      'correoElectronico': 'ana@utng.edu.mx',
      'usuario': {'id': 'u1', 'nombre': 'Ana', 'rol': null, 'cafeteria': null},
    }));
    expect(p.rol, RolUsuario.alumno);
    expect(p.esEncargado, isFalse);
  });

  test('el encargado trae su cafetería', () {
    final p = DataConnectPerfilRepository.aPerfil(
        MiPerfilAutenticacion.fromJson(const {
      'correoElectronico': 'beto@utng.edu.mx',
      'usuario': {
        'id': 'u2',
        'nombre': 'Beto',
        'rol': {'nombre': 'encargado'},
        'cafeteria': {'id': 'c1', 'nombre': 'Central'},
      },
    }));
    expect(p.rol, RolUsuario.encargado);
    expect(p.esEncargado, isTrue);
    expect(p.cafeteriaId, 'c1');
  });

  test('un rol desconocido se trata como alumno', () {
    expect(RolUsuario.desdeNombre('administrador'), RolUsuario.alumno);
  });
}
