import 'dart:convert';
import 'dart:io';

import 'package:agilu/data/models/item_carrito.dart';
import 'package:agilu/data/models/pedido.dart';
import 'package:agilu/data/repositories/dataconnect_menu_repository.dart';
import 'package:agilu/data/repositories/dataconnect_pedido_repository.dart';
import 'package:agilu/data/repositories/firebase_auth_repository.dart';
import 'package:agilu/data/repositories/perfil_repository.dart';
import 'package:agilu/dataconnect_generated/agilu.dart';
import 'package:agilu/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Corre contra los emuladores (ver README):
// firebase emulators:exec --only auth,dataconnect --project demo-agilu
//   "flutter test integration_test -d windows"
Future<void> _sembrarCatalogo() async {
  final cliente = HttpClient();
  final req = await cliente.postUrl(Uri.parse(
      'http://127.0.0.1:9399/v1/projects/demo-agilu/locations/us-east4/'
      'services/agilu-a232a-service:executeGraphql'));
  req.headers.contentType = ContentType.json;
  req.write(jsonEncode({
    'query': File('dataconnect/seed_data.gql').readAsStringSync(),
    'operationName': 'SembrarCatalogo',
  }));
  final res = await req.close();
  final cuerpo = jsonDecode(await res.transform(utf8.decoder).join());
  cliente.close();
  if (res.statusCode != 200 || (cuerpo['errors'] as List).isNotEmpty) {
    throw StateError('No se pudo sembrar el catálogo: $cuerpo');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final correo = 'alumno${DateTime.now().millisecondsSinceEpoch}@utng.edu.mx';
  late FirebaseAuthRepository auth;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    AgiluConnector.instance.dataConnect
        .useDataConnectEmulator('localhost', 9399);
    await _sembrarCatalogo();
    auth = FirebaseAuthRepository(perfil: DataConnectPerfilRepository());
  });

  testWidgets('registro, menú y pedido contra SQL Connect', (tester) async {
    await auth.registrar(correo, '123456', 'Alumno de prueba');
    final perfil = await AgiluConnector.instance.miPerfil().execute();
    expect(perfil.data.autenticacion?.usuario.nombre, 'Alumno de prueba');

    final menu = await DataConnectMenuRepository().observarMenu().first;
    expect(menu, hasLength(6));
    final molletes = menu.firstWhere((p) => p.nombre == 'Molletes');
    final horchata = menu.firstWhere((p) => p.nombre == 'Agua de horchata');

    final folio = await DataConnectPedidoRepository().crearPedido(Pedido(
      usuarioId: auth.uidActual!,
      cafeteriaId: molletes.cafeteriaId,
      items: [
        ItemCarrito(producto: molletes, cantidad: 2),
        ItemCarrito(producto: horchata),
      ],
      total: 100,
      recogerA: DateTime.now().add(const Duration(hours: 1)),
      notas: 'Sin cebolla',
    ));
    expect(folio, matches(RegExp(r'^AGU-\d{5}$')));

    final mios = await AgiluConnector.instance.misPedidos().execute();
    expect(mios.data.pedidos, hasLength(1));
    expect(mios.data.pedidos.single.montoTotal, 100);
    expect(mios.data.pedidos.single.notas, 'Sin cebolla');

    await auth.cerrarSesion();
    await auth.iniciarSesion(correo, '123456');
    final otraVez = await AgiluConnector.instance.misPedidos().execute();
    expect(otraVez.data.pedidos, hasLength(1));
    await auth.cerrarSesion();
  });

  testWidgets('un pedido con un producto no disponible se rechaza',
      (tester) async {
    await auth.registrar('otro$correo', '123456', 'Otro alumno');
    final menu = await DataConnectMenuRepository().observarMenu().first;
    final cafe = menu.firstWhere((p) => !p.disponible);

    await expectLater(
      DataConnectPedidoRepository().crearPedido(Pedido(
        usuarioId: auth.uidActual!,
        cafeteriaId: cafe.cafeteriaId,
        items: [ItemCarrito(producto: cafe)],
        total: cafe.precio,
        recogerA: DateTime.now().add(const Duration(hours: 1)),
      )),
      throwsA(isA<Exception>()),
    );
    final mios = await AgiluConnector.instance.misPedidos().execute();
    expect(mios.data.pedidos, isEmpty);
    await auth.cerrarSesion();
  });
}
