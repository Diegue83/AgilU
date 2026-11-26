import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/data/repositories/estacion_repository.dart';
import 'package:agilu/data/repositories/personal_repository.dart';
import 'package:agilu/data/repositories/producto_repository.dart';
import 'package:agilu/ui/encargado/estaciones/estaciones_view.dart';
import 'package:agilu/ui/encargado/estaciones/estaciones_view_model.dart';
import 'package:agilu/ui/encargado/personal/personal_view_model.dart';
import 'package:agilu/ui/encargado/productos/producto_form_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  test('solo el empleado con estación asignada maneja una estación', () {
    const base = Perfil(
        nombre: 'Luis',
        correo: 'luis@utng.edu.mx',
        rol: RolUsuario.empleado,
        cafeteriaId: 'c1');
    expect(base.tieneEstacion, isFalse);
    const conEstacion = Perfil(
        nombre: 'Luis',
        correo: 'luis@utng.edu.mx',
        rol: RolUsuario.empleado,
        cafeteriaId: 'c1',
        estacionId: 'e1',
        estacion: 'Tortas');
    expect(conEstacion.tieneEstacion, isTrue);
    const alumno =
        Perfil(nombre: 'Ana', correo: 'ana@utng.edu.mx', estacionId: 'e1');
    expect(alumno.tieneEstacion, isFalse);
  });

  group('el encargado asigna la estación', () {
    test('carga las estaciones y asigna o quita la de un empleado', () async {
      final vm = PersonalViewModel(MockPersonalRepository(),
          estaciones: MockEstacionRepository());
      await _esperar();
      expect(vm.estaciones.map((e) => e.id), ['e1', 'e2', 'e3']);

      final luis = vm.personal.firstWhere((m) => m.rol == RolUsuario.empleado);
      expect(luis.estacionId, isNull);
      expect(await vm.asignarEstacion(luis, 'e2'), isTrue);
      expect(
          vm.personal
              .firstWhere((m) => m.usuarioId == luis.usuarioId)
              .estacionId,
          'e2');

      final conEstacion =
          vm.personal.firstWhere((m) => m.usuarioId == luis.usuarioId);
      expect(await vm.asignarEstacion(conEstacion, null), isTrue);
      expect(
          vm.personal
              .firstWhere((m) => m.usuarioId == luis.usuarioId)
              .estacionId,
          isNull);
    });

    test('al encargado no se le asigna estación', () async {
      final vm = PersonalViewModel(MockPersonalRepository(),
          estaciones: MockEstacionRepository());
      await _esperar();
      final yo = vm.personal.firstWhere((m) => m.rol == RolUsuario.encargado);
      expect(await vm.asignarEstacion(yo, 'e1'), isFalse);
      expect(vm.error, contains('debe ser empleado'));
    });
  });

  test('activar o desactivar la estación no toca su nombre ni su orden',
      () async {
    final repo = MockEstacionRepository();
    final vm = EstacionesViewModel(repo);
    await _esperar();
    final tiendita = vm.estaciones.firstWhere((e) => e.id == 'e3');
    expect(await vm.alternarActiva(tiendita), isTrue);
    final despues = vm.estaciones.firstWhere((e) => e.id == 'e3');
    expect(despues.activo, isFalse);
    expect(despues.nombre, tiendita.nombre);
    expect(despues.orden, tiendita.orden);
  });

  test('el empleado edita productos pero no los elimina ni publica ofertas',
      () async {
    final productos = MockProductoRepository();
    final p = (await productos.misProductos()).first;
    final estaciones = await MockEstacionRepository().misEstaciones();
    final vm =
        ProductoFormViewModel(productos, estaciones, actual: p, empleado: true);
    expect(vm.editando, isTrue);
    expect(vm.puedeEliminar, isFalse);
    expect(await vm.eliminar(), isFalse);
    expect((await productos.misProductos()).any((x) => x.id == p.id), isTrue);

    final delEncargado =
        ProductoFormViewModel(productos, estaciones, actual: p);
    expect(delEncargado.puedeEliminar, isTrue);
  });

  testWidgets('el empleado solo ve el interruptor de su estación',
      (tester) async {
    await tester.pumpWidget(
      Provider<EstacionRepository>.value(
        value: MockEstacionRepository(),
        child: const MaterialApp(
            home: Scaffold(body: EstacionesView(empleado: true))),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SwitchListTile), findsNWidgets(3));
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
    expect(find.byType(PopupMenuButton<String>), findsNothing);

    await tester.tap(find.text('Tiendita'));
    await tester.pumpAndSettle();
    expect(find.text('Desactivada: los alumnos no la ven'), findsOneWidget);
  });
}
