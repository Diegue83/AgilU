import 'package:flutter/material.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'ui/auth/login_view.dart';
import 'ui/cart/cart_view.dart';
import 'ui/menu/menu_view.dart';
import 'ui/pedido/confirmacion_view.dart';

class AgilUApp extends StatelessWidget {
  const AgilUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ÁgilU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Routes.login,
      routes: {
        Routes.login: (_) => const LoginView(),
        Routes.menu: (_) => const MenuView(),
        Routes.carrito: (_) => const CartView(),
        Routes.confirmacion: (ctx) => ConfirmacionView(
              folio: ModalRoute.of(ctx)!.settings.arguments as String,
            ),
      },
    );
  }
}
