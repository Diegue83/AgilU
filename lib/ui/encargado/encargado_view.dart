import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/repositories/auth_repository.dart';
import 'cafeteria/cafeteria_view.dart';
import 'estaciones/estaciones_view.dart';
import 'productos/productos_view.dart';

/// Pantalla principal del encargado de la cafetería. Cada sección del panel
/// es una pestaña de la barra inferior.
class EncargadoView extends StatefulWidget {
  const EncargadoView({super.key});

  @override
  State<EncargadoView> createState() => _EncargadoViewState();
}

class _EncargadoViewState extends State<EncargadoView> {
  int _seccion = 0;

  static const _secciones = <(String, IconData, Widget)>[
    ('Productos', Icons.restaurant_menu, ProductosView()),
    ('Estaciones', Icons.storefront, EstacionesView()),
    ('Cafetería', Icons.tune, CafeteriaView()),
  ];

  @override
  Widget build(BuildContext context) {
    final (titulo, _, vista) = _secciones[_seccion];
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthRepository>().cerrarSesion();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
          ),
        ],
      ),
      body: vista,
      bottomNavigationBar: _secciones.length < 2
          ? null
          : NavigationBar(
              selectedIndex: _seccion,
              onDestinationSelected: (i) => setState(() => _seccion = i),
              destinations: [
                for (final (t, icono, _) in _secciones)
                  NavigationDestination(icon: Icon(icono), label: t),
              ],
            ),
    );
  }
}
