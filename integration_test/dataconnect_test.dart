import 'dart:convert';
import 'dart:io';

import 'package:agilu/core/conector.dart';
import 'package:agilu/data/models/item_carrito.dart';
import 'package:agilu/data/models/pedido.dart';
import 'package:agilu/data/repositories/dataconnect_menu_repository.dart';
import 'package:agilu/data/repositories/dataconnect_pedido_repository.dart';
import 'package:agilu/data/repositories/firebase_auth_repository.dart';
import 'package:agilu/data/repositories/perfil_repository.dart';
import 'package:agilu/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Corre contra los emuladores (ver README):
// firebase emulators:exec --only auth,dataconnect --project demo-agilu
//   "flutter test integration_test -d windows"
Future<void> _comoAdmin(String query, [String? operationName]) async {
  final cliente = HttpClient();
  final req = await cliente.postUrl(Uri.parse(
      'http://127.0.0.1:9399/v1/projects/demo-agilu/locations/us-east4/'
      'services/agilu-a232a-service:executeGraphql'));
  req.headers.contentType = ContentType.json;
  req.write(jsonEncode({'query': query, 'operationName': operationName}));
  final res = await req.close();
  final cuerpo = jsonDecode(await res.transform(utf8.decoder).join());
  cliente.close();
  if (res.statusCode != 200 || (cuerpo['errors'] as List).isNotEmpty) {
    throw StateError('Falló la operación de administrador: $cuerpo');
  }
}

/// Catálogo de prueba y la cafetería abierta todo el día, en UTC y sin
/// anticipación, para que la prueba no dependa de la hora en que corre.
Future<void> _sembrarCatalogo() async {
  await _comoAdmin(
      File('dataconnect/seed_data.gql').readAsStringSync(), 'SembrarCatalogo');
  await _comoAdmin('''
    mutation { cafeteria_update(id: "c0000000-0000-4000-8000-000000000001", data: {
      zonaHoraria: "UTC", aperturaMinutos: 0, cierreMinutos: 1439,
      anticipacionMinutos: 0, intervaloMinutos: 1, capacidadPorFranja: 100 }) }
  ''');
}

DateTime _pronto() {
  final t = DateTime.now().toUtc().add(const Duration(minutes: 5));
  return DateTime.utc(t.year, t.month, t.day, t.hour, t.minute);
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
    conectorAgilu.dataConnect.useDataConnectEmulator('localhost', 9399);
    await _sembrarCatalogo();
    auth = FirebaseAuthRepository(perfil: DataConnectPerfilRepository());
  });

  testWidgets('registro, menú y pedido contra SQL Connect', (tester) async {
    await auth.registrar(correo, '123456', 'Alumno de prueba');
    final perfil = await conectorAgilu.miPerfil().execute();
    expect(perfil.data.autenticacion?.usuario.nombre, 'Alumno de prueba');

    final menu = await DataConnectMenuRepository().observarMenu().first;
    expect(menu, hasLength(6));
    final molletes = menu.firstWhere((p) => p.nombre == 'Molletes');
    final horchata = menu.firstWhere((p) => p.nombre == 'Agua de horchata');

    final creado = await DataConnectPedidoRepository().crearPedido(Pedido(
      usuarioId: auth.uidActual!,
      cafeteriaId: molletes.cafeteriaId,
      items: [
        ItemCarrito(producto: molletes, cantidad: 2),
        ItemCarrito(producto: horchata),
      ],
      total: 100,
      recogerA: _pronto(),
      notas: 'Sin cebolla',
    ));
    expect(creado.folio, matches(RegExp(r'^AGU-\d{5}$')));

    final mios = await conectorAgilu.misPedidos().execute();
    expect(mios.data.pedidos, hasLength(1));
    expect(mios.data.pedidos.single.montoTotal, 100);
    expect(mios.data.pedidos.single.notas, 'Sin cebolla');

    await auth.cerrarSesion();
    await auth.iniciarSesion(correo, '123456');
    final otraVez = await conectorAgilu.misPedidos().execute();
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
        recogerA: _pronto(),
      )),
      throwsA(isA<Exception>()),
    );
    final mios = await conectorAgilu.misPedidos().execute();
    expect(mios.data.pedidos, isEmpty);
    await auth.cerrarSesion();
  });
}
