import '../comun/contadores.dart';
import '../cuenta/cuenta_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/permisos.dart';
import '../../core/routes.dart';
import '../../data/models/perfil.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/perfil_repository.dart';
import '../reporte/reporte_view.dart';
import 'cafeteria/cafeteria_view.dart';
import 'estaciones/estaciones_view.dart';
import 'pagos/pagos_view.dart';
import 'panel/panel_view.dart';
import 'personal/personal_view.dart';
import 'productos/productos_view.dart';

/// Pestañas que le tocan a [perfil] según sus permisos.
List<(String, IconData, Widget)> seccionesDelPanel(Perfil? perfil) {
  bool puede(String p) => perfil?.puede(p) ?? false;
  final conEstacion = perfil?.tieneEstacion ?? false;
  return [
    if (puede(Permisos.pedidosAtender))
      ('Pedidos', Icons.receipt_long, const PanelView()),
    if (puede(Permisos.pagosValidar))
      ('Pagos', Icons.payments_outlined, const PagosView()),
    if (puede(Permisos.catalogoGestionar)) ...[
      ('Productos', Icons.restaurant_menu, const ProductosView()),
      ('Estaciones', Icons.storefront, const EstacionesView()),
    ] else if (conEstacion) ...[
      ('Productos', Icons.restaurant_menu, const ProductosView(empleado: true)),
      ('Mi estación', Icons.storefront, const EstacionesView(empleado: true)),
    ],
    if (puede(Permisos.personalGestionar))
      ('Personal', Icons.group_outlined, const PersonalView()),
    if (puede(Permisos.cafeteriaConfigurar))
      ('Cafetería', Icons.tune, const CafeteriaView()),
    if (puede(Permisos.reporteVer))
      ('Reporte', Icons.bar_chart, const ReporteView(enPanel: true)),
  ];
}

/// Pantalla principal del personal de la cafetería. Cada pestaña aparece si el
/// rol tiene el permiso correspondiente; el servidor revisa el mismo permiso en
/// cada operación, esto solo decide qué se muestra.
class EncargadoView extends StatefulWidget {
  const EncargadoView({super.key});

  @override
  State<EncargadoView> createState() => _EncargadoViewState();
}

class _EncargadoViewState extends State<EncargadoView> {
  int _seccion = 0;
  late final Future<Perfil?> _perfil = context
      .read<PerfilRepository>()
      .miPerfil()
      .then((p) => p, onError: (_) => null);

  /// Punto rojo de cada pestaña del panel.
  static int _cuenta(BuildContext context, String seccion) {
    final c = context.watch<ContadoresController>().actual;
    return switch (seccion) {
      'Pedidos' => c.enEspera,
      'Pagos' => c.pagos,
      'Personal' => c.solicitudes,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ConContadores(child: _panel(context));
  }

  Widget _panel(BuildContext context) {
    return FutureBuilder<Perfil?>(
      future: _perfil,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final secciones = seccionesDelPanel(snap.data);
        if (secciones.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Panel'), actions: const [
              BotonMiCuenta(),
            ]),
            body: const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Tu rol todavía no tiene permisos en la cafetería. '
                  'Pide al administrador que te los asigne.'),
            )),
          );
        }
        final i = _seccion.clamp(0, secciones.length - 1);
        final (titulo, _, vista) = secciones[i];
        return Scaffold(
          appBar: AppBar(
            title: Text(titulo),
            actions: [
              if (titulo == 'Pedidos')
                IconButton(
                  tooltip: 'Historial',
                  icon: const Icon(Icons.history),
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.historial),
                ),
              const BotonMiCuenta(),
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await context.read<AuthRepository>().cerrarSesion();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, Routes.login, (_) => false);
                  }
                },
              ),
            ],
          ),
          body: vista,
          bottomNavigationBar: secciones.length < 2
              ? null
              : NavigationBar(
                  selectedIndex: i,
                  onDestinationSelected: (n) => setState(() => _seccion = n),
                  destinations: [
                    for (final (t, icono, _) in secciones)
                      NavigationDestination(
                          icon: IconoConPunto(icono, _cuenta(context, t)),
                          label: t),
                  ],
                ),
        );
      },
    );
  }
}
