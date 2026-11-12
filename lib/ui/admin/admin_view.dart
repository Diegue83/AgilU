import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/models/perfil.dart';
import '../../data/models/personal.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/personal_repository.dart';
import 'admin_view_model.dart';

/// Pantalla del administrador: cafeterías y roles del personal.
class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AdminViewModel(ctx.read<AdminRepository>()),
      child: const _Admin(),
    );
  }
}

class _Admin extends StatefulWidget {
  const _Admin();

  @override
  State<_Admin> createState() => _AdminState();
}

class _AdminState extends State<_Admin> {
  int _seccion = 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_seccion == 0 ? 'Cafeterías' : 'Personal'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _seccion == 0
            ? _editarCafeteria(context, vm)
            : _asignarRol(context, vm),
        icon: Icon(_seccion == 0 ? Icons.add_business : Icons.person_add),
        label: Text(_seccion == 0 ? 'Cafetería' : 'Asignar rol'),
      ),
      body: vm.cargando && vm.cafeterias.isEmpty && vm.personal.isEmpty
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
                  if (_seccion == 0) ..._cafeterias(context, vm),
                  if (_seccion == 1) ..._personal(context, vm),
                ],
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seccion,
        onDestinationSelected: (i) => setState(() => _seccion = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.storefront), label: 'Cafeterías'),
          NavigationDestination(
              icon: Icon(Icons.group_outlined), label: 'Personal'),
        ],
      ),
    );
  }

  List<Widget> _cafeterias(BuildContext context, AdminViewModel vm) => [
        if (vm.cafeterias.isEmpty && vm.error == null)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Aún no hay cafeterías. Agrega la primera.'),
          ),
        for (final c in vm.cafeterias)
          ListTile(
            leading: const Icon(Icons.storefront),
            title: Text(c.nombre),
            subtitle: Text([
              if (c.ubicacion != null) c.ubicacion!,
              c.activa ? 'Activa' : 'Inactiva',
            ].join(' · ')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: c.activa,
                  onChanged: (v) => vm.editarCafeteria(c.copiar(activa: v)),
                ),
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _editarCafeteria(context, vm, actual: c),
                ),
              ],
            ),
          ),
      ];

  List<Widget> _personal(BuildContext context, AdminViewModel vm) => [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text('Para quitar un rol, asígnale "Alumno". La persona '
              'debe tener una cuenta registrada en la app.'),
        ),
        if (vm.personal.isEmpty && vm.error == null)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Nadie tiene un rol todavía.'),
          ),
        for (final m in vm.personal)
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: Text(m.nombre),
            subtitle: Text([
              etiquetaRol(m.rol),
              if (m.cafeteria != null) m.cafeteria!,
              m.correo,
            ].join(' · ')),
            trailing: m.rol == RolUsuario.admin
                ? null
                : IconButton(
                    tooltip: 'Cambiar rol',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _asignarRol(context, vm, actual: m),
                  ),
          ),
      ];

  Future<void> _editarCafeteria(BuildContext context, AdminViewModel vm,
      {CafeteriaAdmin? actual}) async {
    final nombre = TextEditingController(text: actual?.nombre ?? '');
    final ubicacion = TextEditingController(text: actual?.ubicacion ?? '');
    String? problema;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(actual == null ? 'Nueva cafetería' : 'Editar cafetería'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombre,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    InputDecoration(labelText: 'Nombre', errorText: problema),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ubicacion,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Ubicación (ej. Edificio A)'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final p = vm.validarNombreCafeteria(nombre.text,
                    exceptoId: actual?.id);
                if (p != null) {
                  setState(() => problema = p);
                } else {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    if (actual == null) {
      await vm.crearCafeteria(nombre.text, ubicacion.text);
    } else {
      final u = ubicacion.text.trim();
      await vm.editarCafeteria(CafeteriaAdmin(
        id: actual.id,
        nombre: nombre.text.trim(),
        ubicacion: u.isEmpty ? null : u,
        activa: actual.activa,
      ));
    }
  }

  Future<void> _asignarRol(BuildContext context, AdminViewModel vm,
      {MiembroPersonal? actual}) async {
    final correo = TextEditingController(text: actual?.correo ?? '');
    var rol = actual?.rol ?? RolUsuario.empleado;
    String? cafeteriaId =
        vm.cafeteriasActivas.any((c) => c.id == actual?.cafeteriaId)
            ? actual?.cafeteriaId
            : null;
    String? problema;
    const asignables = [
      RolUsuario.empleado,
      RolUsuario.encargado,
      RolUsuario.beneficiaria,
      RolUsuario.admin,
      RolUsuario.alumno,
    ];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Asignar rol'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: correo,
                  enabled: actual == null,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(labelText: 'Correo de la cuenta'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RolUsuario>(
                  initialValue: rol,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: [
                    for (final r in asignables)
                      DropdownMenuItem(
                        value: r,
                        child: Text(r == RolUsuario.alumno
                            ? 'Alumno (quitar rol)'
                            : etiquetaRol(r)),
                      ),
                  ],
                  onChanged: (r) => setState(() => rol = r ?? rol),
                ),
                if (AdminViewModel.necesitaCafeteria(rol)) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: cafeteriaId,
                    decoration: const InputDecoration(labelText: 'Cafetería'),
                    items: [
                      for (final c in vm.cafeteriasActivas)
                        DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                    ],
                    onChanged: (v) => setState(() => cafeteriaId = v),
                  ),
                ],
                if (problema != null) ...[
                  const SizedBox(height: 12),
                  Text(problema!,
                      style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final p = vm.validarAsignacion(correo.text, rol, cafeteriaId);
                if (p != null) {
                  setState(() => problema = p);
                } else {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) await vm.asignarRol(correo.text, rol, cafeteriaId);
  }
}
