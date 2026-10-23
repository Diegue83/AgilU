import 'package:flutter/material.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'data/models/pedido.dart';
import 'ui/auth/login_view.dart';
import 'ui/cart/cart_view.dart';
import 'ui/menu/menu_view.dart';
import 'ui/pedido/confirmacion_view.dart';

class AgilUApp extends StatelessWidget {
  final String rutaInicial;
  const AgilUApp({super.key, this.rutaInicial = Routes.login});

  static final Map<String, WidgetBuilder> _rutas = {
    Routes.login: (_) => const LoginView(),
    Routes.menu: (_) => const MenuView(),
    Routes.carrito: (_) => const CartView(),
    Routes.confirmacion: (ctx) => ConfirmacionView(
          resultado: ModalRoute.of(ctx)!.settings.arguments as ResultadoPedido,
        ),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ÁgilU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: rutaInicial,
      onGenerateInitialRoutes: (ruta) => [
        MaterialPageRoute(
          settings: RouteSettings(name: ruta),
          builder: _rutas[ruta] ?? _rutas[Routes.login]!,
        ),
      ],
      routes: _rutas,
    );
  }
}
