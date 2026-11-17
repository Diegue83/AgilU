import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/avisos_repository.dart';
import '../../data/repositories/perfil_repository.dart';
import 'registro_view_model.dart';

class RegistroView extends StatelessWidget {
  /// true = "Solicitar trabajo": registro de empleado en espera de aprobación.
  final bool empleado;
  const RegistroView({super.key, this.empleado = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => RegistroViewModel(ctx.read<AuthRepository>(),
          perfiles: ctx.read<PerfilRepository>(), empleado: empleado),
      child: const _Registro(),
    );
  }
}

class _Registro extends StatefulWidget {
  const _Registro();

  @override
  State<_Registro> createState() => _RegistroState();
}

class _RegistroState extends State<_Registro> {
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmacion = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _nombre,
      _apellidos,
      _telefono,
      _correo,
      _contrasena,
      _confirmacion
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _crearCuenta(RegistroViewModel vm) async {
    final ok =
        await vm.registrar(_correo.text, _contrasena.text, _confirmacion.text);
    if (!ok || !mounted) return;
    final perfiles = context.read<PerfilRepository>();
    final avisos = context.read<AvisosRepository>();
    final nav = Navigator.of(context);
    final perfil =
        await perfiles.miPerfil().then((p) => p, onError: (_) => null);
    avisos.registrar().ignore();
    nav.pushNamedAndRemoveUntil(Routes.inicioPara(perfil), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistroViewModel>();
    final error = vm.error == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(vm.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          );
    return Scaffold(
      appBar: AppBar(
          title: Text(vm.empleado ? 'Solicitar trabajo' : 'Crear cuenta')),
      body: SafeArea(
        // Arriba y no centrado: el Stepper es una lista y, centrado, dejaba un
        // hueco grande sobre el formulario.
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Stepper(
              currentStep: vm.paso,
              onStepTapped: (i) {
                if (i == 0) vm.regresar();
              },
              controlsBuilder: (context, detalles) =>
                  detalles.stepIndex != detalles.currentStep
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: vm.cargando
                                      ? null
                                      : () => vm.paso == 0
                                          ? vm.continuar(_nombre.text,
                                              _apellidos.text, _telefono.text)
                                          : _crearCuenta(vm),
                                  child: vm.cargando
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : Text(vm.paso == 0
                                          ? 'Continuar'
                                          : 'Crear cuenta'),
                                ),
                              ),
                              if (vm.paso == 1) ...[
                                const SizedBox(width: 12),
                                TextButton(
                                    onPressed: vm.cargando ? null : vm.regresar,
                                    child: const Text('Atrás')),
                              ],
                            ],
                          ),
                        ),
              steps: [
                Step(
                  title: const Text('Datos personales'),
                  subtitle: const Text('Cómo te identifica la cafetería'),
                  isActive: vm.paso >= 0,
                  state: vm.paso > 0 ? StepState.complete : StepState.editing,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nombre,
                        textCapitalization: TextCapitalization.words,
                        decoration:
                            const InputDecoration(labelText: 'Nombre(s)'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _apellidos,
                        textCapitalization: TextCapitalization.words,
                        decoration:
                            const InputDecoration(labelText: 'Apellidos'),
                      ),
                      const SizedBox(height: 12),
                      if (vm.empleado) ...[
                        const SizedBox(height: 12),
                        if (vm.cargandoCafeterias)
                          const LinearProgressIndicator()
                        else
                          DropdownButtonFormField<String>(
                            initialValue: vm.cafeteriaId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Cafetería donde trabajas'),
                            items: [
                              for (final c in vm.cafeterias)
                                DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.etiqueta,
                                        overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: vm.elegirCafeteria,
                          ),
                        const SizedBox(height: 4),
                        const Text(
                          'El encargado de la cafetería debe aprobar tu '
                          'cuenta antes de que puedas atender pedidos.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        controller: _telefono,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono (opcional)',
                          helperText: '10 dígitos',
                        ),
                      ),
                      if (vm.paso == 0 && error != null) error,
                    ],
                  ),
                ),
                Step(
                  title: const Text('Credenciales'),
                  subtitle: const Text('Con esto inicias sesión'),
                  isActive: vm.paso >= 1,
                  state: vm.paso == 1 ? StepState.editing : StepState.indexed,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _correo,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            labelText: 'Correo institucional'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contrasena,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          helperText: 'Mínimo 6 caracteres',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmacion,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Confirma la contraseña'),
                      ),
                      if (vm.paso == 1 && error != null) error,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
