import 'package:agilu/core/routes.dart';
import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/perfil_repository.dart';
import 'package:agilu/data/repositories/personal_repository.dart';
import 'package:agilu/ui/auth/registro_view_model.dart';
import 'package:agilu/ui/auth/solicitud_view.dart';
import 'package:agilu/ui/encargado/personal/personal_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  group('solicitar trabajo', () {
    test('carga las cafeterías y exige elegir una', () async {
      final vm = RegistroViewModel(MockAuthRepository(),
          perfiles: MockPerfilRepository(), empleado: true);
      await _esperar();
      expect(vm.cafeterias.map((c) => c.nombre), contains('Barra de café'));
      expect(vm.continuar('Rosa', 'Medina', ''), isFalse);
      expect(vm.error, 'Elige la cafetería donde trabajas.');
      vm.elegirCafeteria('c2');
      expect(vm.continuar('Rosa', 'Medina', ''), isTrue);
    });

    test('la solicitud viaja con los datos del registro', () async {
      final auth = MockAuthRepository();
      final vm = RegistroViewModel(auth,
          perfiles: MockPerfilRepository(), empleado: true);
      await _esperar();
      vm.elegirCafeteria('c1');
      vm.continuar('Rosa', 'Medina', '');
      expect(await vm.registrar('rosa@correo.com', '123456', '123456'), isTrue);
      expect(auth.registrado?.cafeteriaSolicitada, 'c1');
    });

    test('el registro de alumno no pide cafetería ni envía solicitud',
        () async {
      final auth = MockAuthRepository();
      final vm = RegistroViewModel(auth, perfiles: MockPerfilRepository());
      expect(vm.cafeterias, isEmpty);
      expect(vm.continuar('Ana', 'López', ''), isTrue);
      await vm.registrar('ana@utng.edu.mx', '123456', '123456');
      expect(auth.registrado?.cafeteriaSolicitada, isNull);
    });

    test('el perfil de empleado queda en espera y abre su perfil vacío',
        () async {
      final perfiles = MockPerfilRepository();
      await perfiles.crearPerfilEmpleado('Rosa Medina', null, 'c1');
      final p = (await perfiles.miPerfil())!;
      expect(p.esperandoAprobacion, isTrue);
      expect(p.solicitudCafeteria, 'Cafetería central');
      expect(Routes.inicioPara(p), Routes.solicitud);
      const yaEmpleado = Perfil(
          nombre: 'Rosa',
          correo: 'rosa@correo.com',
          rol: RolUsuario.empleado,
          cafeteriaId: 'c1',
          solicitudCafeteria: 'Cafetería central');
      expect(Routes.inicioPara(yaEmpleado), Routes.encargado);
    });
  });

  group('aprobación del encargado', () {
    test('aprobar convierte la solicitud en empleado', () async {
      final vm = PersonalViewModel(MockPersonalRepository());
      await _esperar();
      final s = vm.solicitudes.single;
      expect(await vm.aprobar(s), isTrue);
      expect(vm.solicitudes, isEmpty);
      expect(
          vm.personal
              .any((p) => p.correo == s.correo && p.rol == RolUsuario.empleado),
          isTrue);
    });

    test('rechazar la quita sin dar de alta', () async {
      final vm = PersonalViewModel(MockPersonalRepository());
      await _esperar();
      final s = vm.solicitudes.single;
      expect(await vm.rechazar(s), isTrue);
      expect(vm.solicitudes, isEmpty);
      expect(vm.personal.any((p) => p.correo == s.correo), isFalse);
      expect(await vm.rechazar(s), isFalse);
      expect(vm.error, 'Esa solicitud ya no existe.');
    });
  });

  group('perfil en espera', () {
    Widget app(MockPerfilRepository perfiles) => MultiProvider(
          providers: [
            Provider<AuthRepository>.value(value: MockAuthRepository()),
            Provider<PerfilRepository>.value(value: perfiles),
          ],
          child: MaterialApp(
            routes: {
              '/': (_) => const SolicitudView(),
              Routes.encargado: (_) => const Scaffold(body: Text('PANEL')),
            },
          ),
        );

    const pendiente = Perfil(
        nombre: 'Rosa',
        correo: 'rosa@correo.com',
        solicitudCafeteria: 'Cafetería central');

    testWidgets('solo muestra el aviso de espera', (tester) async {
      await tester.pumpWidget(app(MockPerfilRepository(perfil: pendiente)));
      await tester.pumpAndSettle();
      expect(find.text('Mi perfil'), findsOneWidget);
      expect(
          find.text('En espera de aprobación del encargado.'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('al aprobarla, deslizar para revisar entra al panel',
        (tester) async {
      final perfiles = MockPerfilRepository(perfil: pendiente);
      await tester.pumpWidget(app(perfiles));
      await tester.pumpAndSettle();
      perfiles.perfil = const Perfil(
          nombre: 'Rosa',
          correo: 'rosa@correo.com',
          rol: RolUsuario.empleado,
          cafeteriaId: 'c1');
      await tester.fling(find.text('En espera de aprobación del encargado.'),
          const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('PANEL'), findsOneWidget);
    });
  });

  testWidgets('el login ofrece solicitar trabajo', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: MockAuthRepository()),
        Provider<PerfilRepository>.value(value: MockPerfilRepository()),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, Routes.registroEmpleado),
            child: const Text('ir'),
          ),
        ),
        routes: {
          Routes.registroEmpleado: (_) =>
              const Scaffold(body: Text('REGISTRO EMPLEADO')),
        },
      ),
    ));
    await tester.tap(find.text('ir'));
    await tester.pumpAndSettle();
    expect(find.text('REGISTRO EMPLEADO'), findsOneWidget);
  });
}
