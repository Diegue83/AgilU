import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'data/models/pedido.dart';
import 'data/repositories/avisos_repository.dart';
import 'ui/admin/admin_view.dart';
import 'ui/auth/login_view.dart';
import 'ui/avisos/avisos_view.dart';
import 'ui/auth/registro_view.dart';
import 'ui/cart/cart_view.dart';
import 'ui/cuenta/cuenta_view.dart';
import 'ui/encargado/encargado_view.dart';
import 'ui/encargado/historial/historial_view.dart';
import 'ui/menu/menu_view.dart';
import 'ui/pedido/confirmacion_view.dart';
import 'ui/reporte/reporte_view.dart';

class AgilUApp extends StatefulWidget {
  final String rutaInicial;
  const AgilUApp({super.key, this.rutaInicial = Routes.login});

  @override
  State<AgilUApp> createState() => _AgilUAppState();
}

class _AgilUAppState extends State<AgilUApp> {
  final _mensajero = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<String>? _avisos;

  @override
  void initState() {
    super.initState();
    // HU-05: con la app abierta, el aviso se muestra como SnackBar.
    _avisos = context.read<AvisosRepository>().enPrimerPlano.listen((texto) {
      _mensajero.currentState?.showSnackBar(SnackBar(content: Text(texto)));
    });
  }

  @override
  void dispose() {
    _avisos?.cancel();
    super.dispose();
  }

  static final Map<String, WidgetBuilder> _rutas = {
    Routes.login: (_) => const LoginView(),
    Routes.registro: (_) => const RegistroView(),
    Routes.menu: (_) => const MenuView(),
    Routes.carrito: (_) => const CartView(),
    Routes.encargado: (_) => const EncargadoView(),
    Routes.reporte: (_) => const ReporteView(),
    Routes.admin: (_) => const AdminView(),
    Routes.cuenta: (_) => const CuentaView(),
    Routes.avisos: (_) => const AvisosView(),
    Routes.historial: (_) => const HistorialView(),
    Routes.confirmacion: (ctx) => ConfirmacionView(
          resultado: ModalRoute.of(ctx)!.settings.arguments as ResultadoPedido,
        ),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _mensajero,
      title: 'ÁgilU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: widget.rutaInicial,
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
