import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/perfil.dart';
import '../../../data/models/personal.dart';
import '../../../data/repositories/personal_repository.dart';
import 'personal_view_model.dart';

class PersonalView extends StatelessWidget {
  const PersonalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PersonalViewModel(ctx.read<PersonalRepository>()),
      child: const _Personal(),
    );
  }
}

/// Diálogo para escribir un correo; [validar] devuelve el problema o null.
Future<String?> pedirCorreo(BuildContext context,
    {required String titulo,
    required String ayuda,
    required String? Function(String) validar}) {
  final ctrl = TextEditingController();
  String? problema;
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ayuda),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo de la cuenta',
                errorText: problema,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final p = validar(ctrl.text);
              if (p != null) {
                setState(() => problema = p);
              } else {
                Navigator.pop(ctx, ctrl.text.trim());
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    ),
  );
}

class _Personal extends StatelessWidget {
  const _Personal();

  Future<void> _confirmarQuitar(
      BuildContext context, PersonalViewModel vm, MiembroPersonal m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Quitar a ${m.nombre}?'),
        content: const Text(
            'Dejará de ver el panel de pedidos. Su cuenta sigue existiendo '
            'como alumno.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Quitar')),
        ],
      ),
    );
    if (ok == true) await vm.quitar(m);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PersonalViewModel>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final correo = await pedirCorreo(
            context,
            titulo: 'Nuevo empleado',
            ayuda: 'La persona debe registrarse antes en la app. Podrá '
                'atender y entregar pedidos, pero no validar pagos ni '
                'cambiar el menú.',
            validar: vm.validarCorreo,
          );
          if (correo != null) await vm.agregar(correo);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Empleado'),
      ),
      body: vm.cargando && vm.personal.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: vm.cargar,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 88),
                children: [
                  if (vm.error != null)
                    MaterialBanner(
                      content: Text(vm.error!),
                      actions: [
                        TextButton(
                            onPressed: vm.cargar,
                            child: const Text('Reintentar')),
                      ],
                    ),
                  if (vm.solicitudes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                          'Solicitudes de empleo (${vm.solicitudes.length})',
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    for (final s in vm.solicitudes)
                      Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.nombre,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              Text([
                                s.correo,
                                if (s.telefono != null) s.telefono!,
                              ].join(' · ')),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () => vm.aprobar(s),
                                      child: const Text('Aprobar'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => vm.rechazar(s),
                                      child: const Text('Rechazar'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const Divider(height: 24),
                  ],
                  for (final m in vm.personal)
                    ListTile(
                      leading: Icon(m.rol == RolUsuario.encargado
                          ? Icons.manage_accounts
                          : Icons.badge_outlined),
                      title: Text(m.nombre),
                      subtitle: Text('${etiquetaRol(m.rol)} · ${m.correo}'),
                      trailing: m.rol == RolUsuario.empleado
                          ? IconButton(
                              tooltip: 'Quitar',
                              icon: const Icon(Icons.person_remove_outlined),
                              onPressed: () => _confirmarQuitar(context, vm, m),
                            )
                          : null,
                    ),
                  if (vm.personal.length <= 1 && vm.error == null)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aún no tienes empleados. Agrega al primero '
                          'con su correo.'),
                    ),
                ],
              ),
            ),
    );
  }
}
