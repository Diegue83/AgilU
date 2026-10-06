import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/app_config.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/firebase_auth_repository.dart';
import 'data/repositories/firestore_menu_repository.dart';
import 'data/repositories/firestore_pedido_repository.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/pedido_repository.dart';
import 'ui/cart/cart_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.usarFirebase) {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        // Capa de datos: se elige la implementación según AppConfig.
        Provider<AuthRepository>(
          create: (_) => AppConfig.usarFirebase
              ? FirebaseAuthRepository()
              : MockAuthRepository(),
        ),
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
      child: const AgilUApp(),
    ),
  );
}
