import '../cuenta/cuenta_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/permisos.dart';
import '../../data/models/personal.dart';
import '../../data/models/rol.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/personal_repository.dart';
import 'admin_view_model.dart';

/// Pantalla del administrador: cafeterías, personal y roles con sus permisos.
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
        title: Text(const ['Cafeterías', 'Personal', 'Roles'][_seccion]),
        actions: [
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => switch (_seccion) {
          0 => _editarCafeteria(context, vm),
          1 => _asignarRol(context, vm),
          _ => _crearRol(context, vm),
        },
        icon: Icon(const [
          Icons.add_business,
          Icons.person_add,
          Icons.add_moderator_outlined
        ][_seccion]),
        label: Text(const ['Cafetería', 'Asignar rol', 'Rol'][_seccion]),
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
                  if (_seccion == 2) ..._roles(context, vm),
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
          NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined), label: 'Roles'),
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
              m.etiqueta,
              if (m.cafeteria != null) m.cafeteria!,
              m.correo,
            ].join(' · ')),
            trailing: m.nombreRol == 'admin'
                ? null
                : IconButton(
                    tooltip: 'Cambiar rol',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _asignarRol(context, vm, actual: m),
                  ),
          ),
      ];

  List<Widget> _roles(BuildContext context, AdminViewModel vm) => [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Los permisos deciden qué puede hacer cada rol; el '
              'servidor los revisa en cada operación. El alumno no lleva '
              'permisos y el administrador siempre conserva el suyo.'),
        ),
        for (final r in vm.roles)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ExpansionTile(
              key: PageStorageKey('rol-${r.id}'),
              leading: Icon(r.esDeSistema
                  ? Icons.verified_user_outlined
                  : Icons.badge_outlined),
              title: Text(r.etiqueta),
              subtitle: Text([
                if (r.descripcion != null) r.descripcion!,
                '${r.permisos.length} permiso(s) · ${r.usuarios} cuenta(s)',
              ].join(' · ')),
              trailing: PopupMenuButton<String>(
                tooltip: 'Opciones del rol',
                onSelected: (op) => op == 'editar'
                    ? _editarDescripcion(context, vm, r)
                    : _confirmarEliminarRol(context, vm, r),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'editar', child: Text('Editar descripción')),
                  PopupMenuItem(
                    value: 'eliminar',
                    enabled: r.sePuedeEliminar,
                    child: Text(r.esDeSistema
                        ? 'Eliminar (rol de sistema)'
                        : r.usuarios > 0
                            ? 'Eliminar (tiene cuentas)'
                            : 'Eliminar'),
                  ),
                ],
              ),
              children: [
                for (final p in vm.permisos)
                  SwitchListTile(
                    dense: true,
                    title: Text(p.nombre),
                    subtitle: Text(p.codigo),
                    value: r.permisos.contains(p.codigo),
                    onChanged: vm.puedeCambiar(r, p.codigo)
                        ? (v) => vm.cambiarPermiso(r, p.codigo, v)
                        : null,
                  ),
              ],
            ),
          ),
      ];

  Future<void> _crearRol(BuildContext context, AdminViewModel vm) async {
    final nombre = TextEditingController();
    final descripcion = TextEditingController();
    String? problema;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nuevo rol'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombre,
                autofocus: true,
                decoration: InputDecoration(
                    labelText: 'Nombre (ej. cajero)', errorText: problema),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descripcion,
                maxLength: 120,
                decoration:
                    const InputDecoration(labelText: 'Descripción (opcional)'),
              ),
              const Text(
                  'Se crea sin permisos; después actívalos en la lista.'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final p = vm.validarNombreRol(nombre.text);
                if (p != null) {
                  setState(() => problema = p);
                } else {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) await vm.crearRol(nombre.text, descripcion.text);
  }

  Future<void> _editarDescripcion(
      BuildContext context, AdminViewModel vm, RolAdmin r) async {
    final ctrl = TextEditingController(text: r.descripcion ?? '');
    final texto = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Descripción de ${r.etiqueta}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(labelText: 'Descripción'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (texto != null) await vm.editarRol(r, texto);
  }

  Future<void> _confirmarEliminarRol(
      BuildContext context, AdminViewModel vm, RolAdmin r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar el rol ${r.etiqueta}?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) await vm.eliminarRol(r);
  }

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
    final nombres = [
      for (final r in vm.roles)
        if (r.nombre != 'alumno') r.nombre,
      'alumno',
    ];
    var rol = actual?.nombreRol != null && nombres.contains(actual!.nombreRol)
        ? actual.nombreRol!
        : (nombres.contains('empleado') ? 'empleado' : nombres.first);
    String? cafeteriaId =
        vm.cafeteriasActivas.any((c) => c.id == actual?.cafeteriaId)
            ? actual?.cafeteriaId
            : null;
    String? problema;
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
                DropdownButtonFormField<String>(
                  initialValue: rol,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: [
                    for (final r in nombres)
                      DropdownMenuItem(
                        value: r,
                        child: Text(r == 'alumno'
                            ? 'Alumno (quitar rol)'
                            : etiquetaRolNombre(r)),
                      ),
                  ],
                  onChanged: (r) => setState(() => rol = r ?? rol),
                ),
                if (vm.necesitaCafeteria(rol)) ...[
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
