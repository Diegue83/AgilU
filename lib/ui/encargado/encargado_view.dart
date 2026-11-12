import '../cuenta/cuenta_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/models/perfil.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/perfil_repository.dart';
import 'cafeteria/cafeteria_view.dart';
import 'estaciones/estaciones_view.dart';
import 'pagos/pagos_view.dart';
import 'panel/panel_view.dart';
import 'personal/personal_view.dart';
import 'productos/productos_view.dart';

/// Pantalla principal del personal de la cafetería. El encargado ve todas las
/// secciones; el empleado solo el panel de pedidos. El servidor aplica la
/// misma regla en cada operación, esto solo decide qué se muestra.
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

  static const _delEncargado = <(String, IconData, Widget)>[
    ('Pedidos', Icons.receipt_long, PanelView()),
    ('Pagos', Icons.payments_outlined, PagosView()),
    ('Productos', Icons.restaurant_menu, ProductosView()),
    ('Estaciones', Icons.storefront, EstacionesView()),
    ('Personal', Icons.group_outlined, PersonalView()),
    ('Cafetería', Icons.tune, CafeteriaView()),
  ];

  static const _delEmpleado = <(String, IconData, Widget)>[
    ('Pedidos', Icons.receipt_long, PanelView()),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Perfil?>(
      future: _perfil,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final secciones =
            snap.data?.esEncargado == true ? _delEncargado : _delEmpleado;
        final i = _seccion.clamp(0, secciones.length - 1);
        final (titulo, _, vista) = secciones[i];
        return Scaffold(
          appBar: AppBar(
            title: Text(titulo),
            actions: [
              if (i == 0)
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
                      NavigationDestination(icon: Icon(icono), label: t),
                  ],
                ),
        );
      },
    );
  }
}
