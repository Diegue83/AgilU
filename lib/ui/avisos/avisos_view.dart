import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/repositories/bandeja_repository.dart';
import '../comun/contadores.dart';

/// Bandeja de avisos: los últimos avisos del usuario. Al abrirla se marcan
/// como leídos.
class AvisosViewModel extends ChangeNotifier {
  final BandejaRepository _repo;
  AvisosViewModel(this._repo) {
    cargar();
  }

  List<Aviso> avisos = [];
  bool cargando = true;
  String? error;

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      avisos = await _repo.misAvisos();
      error = null;
      if (avisos.any((a) => !a.leido)) {
        await _repo.marcarLeidos().then((_) {}, onError: (Object _) {});
      }
    } catch (_) {
      error = 'No se pudieron cargar tus avisos.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}

class AvisosView extends StatelessWidget {
  const AvisosView({super.key});

  static String _fecha(DateTime f) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)} ${dos(f.hour)}:${dos(f.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AvisosViewModel(ctx.read<BandejaRepository>()),
      child: Consumer<AvisosViewModel>(
        builder: (context, vm, _) => Scaffold(
          appBar: AppBar(title: const Text('Avisos')),
          body: vm.cargando && vm.avisos.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: vm.cargar,
                  child: ListView(
                    children: [
                      if (vm.error != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(vm.error!),
                        ),
                      if (vm.avisos.isEmpty && vm.error == null)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No tienes avisos. Aquí verás cuando tu '
                              'pago se valide o tu pedido esté listo.'),
                        ),
                      for (final a in vm.avisos)
                        ListTile(
                          leading: Icon(
                            a.leido
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                            color: a.leido
                                ? null
                                : Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(a.titulo,
                              style: TextStyle(
                                  fontWeight: a.leido
                                      ? FontWeight.normal
                                      : FontWeight.bold)),
                          subtitle: Text(a.mensaje),
                          trailing: Text(_fecha(a.fecha),
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Campana de la barra superior con el número de avisos sin leer.
class BotonAvisos extends StatelessWidget {
  const BotonAvisos({super.key});

  @override
  Widget build(BuildContext context) {
    final contadores = context.watch<ContadoresController>();
    return IconButton(
      tooltip: 'Avisos',
      icon:
          IconoConPunto(Icons.notifications_outlined, contadores.actual.avisos),
      onPressed: () async {
        await Navigator.pushNamed(context, Routes.avisos);
        contadores.actualizar();
      },
    );
  }
}
