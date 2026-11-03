import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/app_config.dart';
import 'core/routes.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/dataconnect_menu_repository.dart';
import 'data/repositories/dataconnect_pedido_repository.dart';
import 'data/repositories/estacion_repository.dart';
import 'data/repositories/firebase_auth_repository.dart';
import 'data/repositories/foto_repository.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/pedido_repository.dart';
import 'data/repositories/producto_repository.dart';
import 'data/repositories/perfil_repository.dart';
import 'dataconnect_generated/agilu.dart';
import 'firebase_options.dart';
import 'ui/cart/cart_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.usarFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (AppConfig.usarEmuladores) {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      AgiluConnector.instance.dataConnect
          .useDataConnectEmulator('localhost', 9399);
      FirebaseFunctions.instanceFor(region: 'us-east4')
          .useFunctionsEmulator('localhost', 5001);
    }
  }

  // Capa de datos: se elige la implementación según AppConfig.
  final PerfilRepository perfiles = AppConfig.usarFirebase
      ? DataConnectPerfilRepository()
      : MockPerfilRepository();
  final AuthRepository auth = AppConfig.usarFirebase
      ? FirebaseAuthRepository(perfil: perfiles)
      : MockAuthRepository();
  final sesion = await auth.sesionGuardada();
  final perfil = sesion == null
      ? null
      : await perfiles.miPerfil().then((p) => p, onError: (_) => null);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: auth),
        Provider<PerfilRepository>.value(value: perfiles),
        Provider<EstacionRepository>(
          create: (_) => AppConfig.usarFirebase
              ? DataConnectEstacionRepository()
              : MockEstacionRepository(),
        ),
        Provider<FotoRepository>(
          create: (_) => AppConfig.usarFirebase
              ? CloudFunctionsFotoRepository()
              : MockFotoRepository(),
        ),
        Provider<ProductoRepository>(
          create: (_) => AppConfig.usarFirebase
              ? DataConnectProductoRepository()
              : MockProductoRepository(),
        ),
        Provider<MenuRepository>(
          create: (_) => AppConfig.usarFirebase
              ? DataConnectMenuRepository()
              : MockMenuRepository(),
        ),
        Provider<PedidoRepository>(
          create: (_) => AppConfig.usarFirebase
              ? DataConnectPedidoRepository()
              : MockPedidoRepository(),
        ),
        // Estado compartido del carrito.
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: AgilUApp(
          rutaInicial:
              sesion == null ? Routes.login : Routes.inicioPara(perfil)),
    ),
  );
}
