import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/app_config.dart';
import 'core/routes.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/firebase_auth_repository.dart';
import 'data/repositories/firestore_menu_repository.dart';
import 'data/repositories/firestore_pedido_repository.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/pedido_repository.dart';
import 'firebase_options.dart';
import 'ui/cart/cart_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.usarFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Capa de datos: se elige la implementación según AppConfig.
  final AuthRepository auth =
      AppConfig.usarFirebase ? FirebaseAuthRepository() : MockAuthRepository();
  final sesion = await auth.sesionGuardada();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: auth),
        Provider<MenuRepository>(
          create: (_) => AppConfig.usarFirebase
              ? FirestoreMenuRepository()
              : MockMenuRepository(),
        ),
        Provider<PedidoRepository>(
          create: (_) => AppConfig.usarFirebase
              ? FirestorePedidoRepository()
              : MockPedidoRepository(),
        ),
        // Estado compartido del carrito.
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: AgilUApp(rutaInicial: sesion == null ? Routes.login : Routes.menu),
    ),
  );
}
