import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/perfil_repository.dart';

/// Perfil de quien solicitó trabajo: vacío, solo con el aviso de que espera la
/// aprobación del encargado. Al deslizar hacia abajo vuelve a revisar; si ya
/// lo aprobaron, entra al panel.
class SolicitudView extends StatefulWidget {
  const SolicitudView({super.key});

  @override
  State<SolicitudView> createState() => _SolicitudViewState();
}

class _SolicitudViewState extends State<SolicitudView> {
  @override
  void initState() {
    super.initState();
    _revisar();
  }

  Future<void> _revisar() async {
    final perfiles = context.read<PerfilRepository>();
    final nav = Navigator.of(context);
    final perfil =
        await perfiles.miPerfil().then((p) => p, onError: (_) => null);
    if (!mounted || perfil == null || perfil.esperandoAprobacion) return;
    nav.pushNamedAndRemoveUntil(Routes.inicioPara(perfil), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
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
      body: RefreshIndicator(
        onRefresh: _revisar,
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_top,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          const Expanded(
                            child:
                                Text('En espera de aprobación del encargado.'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
