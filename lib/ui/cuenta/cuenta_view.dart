import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/models/personal.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import '../../data/repositories/perfil_repository.dart';
import 'cuenta_view_model.dart';

/// Mi cuenta: perfil, datos personales, nivel de confianza y seguridad.
class CuentaView extends StatelessWidget {
  const CuentaView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CuentaViewModel(ctx.read<PerfilRepository>(),
          ctx.read<AuthRepository>(), ctx.read<PedidoRepository>()),
      child: const _Cuenta(),
    );
  }
}

/// Botón de la barra superior que abre Mi cuenta.
class BotonMiCuenta extends StatelessWidget {
  const BotonMiCuenta({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'Mi cuenta',
        icon: const Icon(Icons.account_circle_outlined),
        onPressed: () => Navigator.pushNamed(context, Routes.cuenta),
      );
}

class _Cuenta extends StatelessWidget {
  const _Cuenta();

  Color _colorConfianza(BuildContext context, NivelConfianza n) {
    final esquema = Theme.of(context).colorScheme;
    return switch (n) {
      NivelConfianza.excelente || NivelConfianza.buena => Colors.green.shade700,
      NivelConfianza.enRiesgo => Colors.orange.shade800,
      NivelConfianza.bloqueado => esquema.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CuentaViewModel>();
    final p = vm.perfil;
    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta')),
      body: vm.cargando && p == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: vm.cargar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (vm.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(vm.error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                  if (p != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          child: Text(
                            p.nombre.isEmpty ? '?' : p.nombre[0].toUpperCase(),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.nombre,
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              Text(p.correo),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text([
                                  etiquetaRol(p.rol),
                                  if (p.cafeteria != null) p.cafeteria!,
                                ].join(' · ')),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (vm.esAlumno) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nivel de confianza',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.verified_user,
                                      color: _colorConfianza(
                                          context, vm.confianza)),
                                  const SizedBox(width: 8),
                                  Text(vm.confianza.etiqueta,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _colorConfianza(
                                              context, vm.confianza))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (vm.limiteNoRecogidos - vm.noRecogidos)
                                        .clamp(0, vm.limiteNoRecogidos) /
                                    vm.limiteNoRecogidos,
                                color: _colorConfianza(context, vm.confianza),
                              ),
                              const SizedBox(height: 8),
                              Text(vm.confianza.descripcion),
                              Text(
                                  'Pedidos sin recoger (30 días): '
                                  '${vm.noRecogidos} de ${vm.limiteNoRecogidos}',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text('Datos personales',
                        style: Theme.of(context).textTheme.titleMedium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Nombre'),
                      subtitle: Text(p.nombre),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Teléfono'),
                      subtitle: Text(p.telefono ?? 'Sin registrar'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.mail_outline),
                      title: const Text('Correo'),
                      subtitle: Text(p.correo),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          vm.guardando ? null : () => _editarDatos(context, vm),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar datos'),
                    ),
                    const SizedBox(height: 16),
                    Text('Seguridad',
                        style: Theme.of(context).textTheme.titleMedium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Cambiar contraseña'),
                      onTap: vm.guardando
                          ? null
                          : () => _cambiarContrasena(context, vm),
                    ),
                    if (vm.esAlumno)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_forever_outlined,
                            color: Theme.of(context).colorScheme.error),
                        title: Text('Eliminar mi cuenta',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                        subtitle: const Text(
                            'Borra tus datos personales y tu acceso.'),
                        onTap: vm.guardando
                            ? null
                            : () => _eliminarCuenta(context, vm),
                      ),
                  ],
                ],
              ),
            ),
    );
  }

  /// Diálogo con campos; [validar] devuelve el problema o null.
  Future<bool> _dialogo(
    BuildContext context, {
    required String titulo,
    required List<(TextEditingController, String, bool, TextInputType)> campos,
    required String? Function() validar,
    required String accion,
    Widget? aviso,
  }) async {
    String? problema;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (aviso != null) ...[aviso, const SizedBox(height: 12)],
                for (final (ctrl, etiqueta, oculto, teclado) in campos) ...[
                  TextField(
                    controller: ctrl,
                    obscureText: oculto,
                    keyboardType: teclado,
                    decoration: InputDecoration(labelText: etiqueta),
                  ),
                  const SizedBox(height: 8),
                ],
                if (problema != null)
                  Text(problema!,
                      style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final p = validar();
                if (p != null) {
                  setState(() => problema = p);
                } else {
                  Navigator.pop(ctx, true);
                }
              },
              child: Text(accion),
            ),
          ],
        ),
      ),
    );
    return ok == true;
  }

  Future<void> _editarDatos(BuildContext context, CuentaViewModel vm) async {
    final nombre = TextEditingController(text: vm.perfil?.nombre ?? '');
    final telefono = TextEditingController(text: vm.perfil?.telefono ?? '');
    final ok = await _dialogo(
      context,
      titulo: 'Editar datos',
      campos: [
        (nombre, 'Nombre completo', false, TextInputType.name),
        (telefono, 'Teléfono (opcional)', false, TextInputType.phone),
      ],
      validar: () => vm.validarDatos(nombre.text, telefono.text),
      accion: 'Guardar',
    );
    if (ok) await vm.editarDatos(nombre.text, telefono.text);
  }

  Future<void> _cambiarContrasena(
      BuildContext context, CuentaViewModel vm) async {
    final actual = TextEditingController();
    final nueva = TextEditingController();
    final confirmacion = TextEditingController();
    final ok = await _dialogo(
      context,
      titulo: 'Cambiar contraseña',
      campos: [
        (actual, 'Contraseña actual', true, TextInputType.visiblePassword),
        (nueva, 'Nueva contraseña', true, TextInputType.visiblePassword),
        (
          confirmacion,
          'Confirma la nueva contraseña',
          true,
          TextInputType.visiblePassword
        ),
      ],
      validar: () => actual.text.isEmpty
          ? 'Escribe tu contraseña actual.'
          : vm.validarContrasena(nueva.text, confirmacion.text),
      accion: 'Cambiar',
    );
    if (!ok || !context.mounted) return;
    final mensajero = ScaffoldMessenger.of(context);
    if (await vm.cambiarContrasena(actual.text, nueva.text)) {
      mensajero.showSnackBar(
          const SnackBar(content: Text('Tu contraseña se actualizó.')));
    }
  }

  Future<void> _eliminarCuenta(BuildContext context, CuentaViewModel vm) async {
    final contrasena = TextEditingController();
    final ok = await _dialogo(
      context,
      titulo: '¿Eliminar tu cuenta?',
      aviso: const Text(
          'Se borran tu nombre, teléfono, avisos y acceso. Tus pedidos '
          'anteriores quedan en los reportes de la cafetería sin tus datos. '
          'Esta acción no se puede deshacer.'),
      campos: [
        (
          contrasena,
          'Escribe tu contraseña',
          true,
          TextInputType.visiblePassword
        ),
      ],
      validar: () => contrasena.text.isEmpty ? 'Escribe tu contraseña.' : null,
      accion: 'Eliminar',
    );
    if (!ok || !context.mounted) return;
    final nav = Navigator.of(context);
    if (await vm.eliminarCuenta(contrasena.text)) {
      nav.pushNamedAndRemoveUntil(Routes.login, (_) => false);
    }
  }
}
