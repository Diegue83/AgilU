import 'ui/comun/actualizacion.dart';
import 'ui/comun/contadores.dart';
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
import 'ui/auth/solicitud_view.dart';
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
  final _navegador = GlobalKey<NavigatorState>();
  StreamSubscription<String>? _avisos;
  StreamSubscription<AvisoAbierto>? _abiertos;

  @override
  void initState() {
    super.initState();
    // HU-05: con la app abierta, el aviso se muestra como SnackBar.
    final contadores = context.read<ContadoresController>();
    _avisos = context.read<AvisosRepository>().enPrimerPlano.listen((texto) {
      _mensajero.currentState?.showSnackBar(SnackBar(content: Text(texto)));
      contadores.actualizar();
    });
    // Tocar una notificación abre el ticket del pedido o el panel.
    _abiertos = context.read<AvisosRepository>().abiertos.listen(_abrirAviso);
    WidgetsBinding.instance.addPostFrameCallback((_) => _revisarVersion());
  }

  /// Al abrir la app, si hay un release más nuevo, ofrece actualizar.
  Future<void> _revisarVersion() async {
    final c = actualizadorDe(context);
    if (c == null || !c.soportada) return;
    await c.buscar();
    final ctx = _navegador.currentContext;
    if (c.nueva != null && ctx != null && ctx.mounted) {
      await ofrecerActualizacion(ctx, c);
    }
  }

  void _abrirAviso(AvisoAbierto aviso) {
    final nav = _navegador.currentState;
    if (nav == null) {
      // La app apenas arranca: se intenta en el siguiente cuadro.
      WidgetsBinding.instance
        ..addPostFrameCallback((_) => _abrirAviso(aviso))
        ..scheduleFrame();
      return;
    }
    switch (aviso.destino) {
      case DestinoAviso.ticket:
        nav.push(MaterialPageRoute(
            builder: (_) => TicketView(pedidoId: aviso.pedidoId!)));
      case DestinoAviso.panel:
        nav.pushNamedAndRemoveUntil(Routes.encargado, (_) => false);
      case DestinoAviso.ninguno:
        break;
    }
  }

  @override
  void dispose() {
    _abiertos?.cancel();
    _avisos?.cancel();
    super.dispose();
  }

  static final Map<String, WidgetBuilder> _rutas = {
    Routes.login: (_) => const LoginView(),
    Routes.registro: (_) => const RegistroView(),
    Routes.registroEmpleado: (_) => const RegistroView(empleado: true),
    Routes.menu: (_) => const MenuView(),
    Routes.carrito: (_) => const CartView(),
    Routes.encargado: (_) => const EncargadoView(),
    Routes.reporte: (_) => const ReporteView(),
    Routes.admin: (_) => const AdminView(),
    Routes.cuenta: (_) => const CuentaView(),
    Routes.solicitud: (_) => const SolicitudView(),
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
      navigatorKey: _navegador,
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
