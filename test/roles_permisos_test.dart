import 'package:agilu/core/permisos.dart';
import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/data/models/rol.dart';
import 'package:agilu/data/repositories/personal_repository.dart';
import 'package:agilu/ui/admin/admin_view_model.dart';
import 'package:agilu/ui/encargado/encargado_view.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  group('permisos del perfil', () {
    test('las pestañas del panel siguen los permisos, no el nombre del rol',
        () {
      const cajero = Perfil(
          nombre: 'Caja',
          correo: 'caja@utng.edu.mx',
          rol: RolUsuario.otro,
          nombreRol: 'cajero',
          cafeteriaId: 'c1',
          permisos: {Permisos.pagosValidar, Permisos.pedidosAtender});
      expect(cajero.esPersonal, isTrue);
      expect(cajero.esAdmin, isFalse);
      expect(cajero.etiquetaRol, 'Cajero');
      expect(seccionesDelPanel(cajero).map((s) => s.$1), ['Pedidos', 'Pagos']);

      const encargado = Perfil(
          nombre: 'Beto',
          correo: 'beto@utng.edu.mx',
          rol: RolUsuario.encargado,
          cafeteriaId: 'c1');
      expect(seccionesDelPanel(encargado).map((s) => s.$1), [
        'Pedidos',
        'Pagos',
        'Productos',
        'Estaciones',
        'Personal',
        'Cafetería',
        'Reporte',
      ]);
    });

    test('un rol desconocido no es alumno ni personal sin permisos', () {
      expect(RolUsuario.desdeNombre('cajero'), RolUsuario.otro);
      expect(RolUsuario.desdeNombre(null), RolUsuario.alumno);
      const sinPermisos = Perfil(
          nombre: 'X',
          correo: 'x@utng.edu.mx',
          rol: RolUsuario.otro,
          nombreRol: 'invitado',
          cafeteriaId: 'c1',
          permisos: {});
      expect(sinPermisos.esPersonal, isFalse);
      expect(seccionesDelPanel(sinPermisos), isEmpty);
    });

    test('el alumno no lleva permisos y el admin no pierde el suyo', () {
      expect(Permisos.sePuedeCambiar('alumno', Permisos.pagosValidar), isFalse);
      expect(
          Permisos.sePuedeCambiar('admin', Permisos.adminGestionar), isFalse);
      expect(Permisos.sePuedeCambiar('admin', Permisos.reporteVer), isTrue);
      expect(
          Permisos.sePuedeCambiar('cajero', Permisos.adminGestionar), isTrue);
    });

    test('se lee la fila de RolesAdmin', () {
      final r = RolAdmin.desdeMapa(const {
        'id': 'r1',
        'nombre': 'cajero',
        'descripcion': null,
        'permisos': ['pagos.validar'],
        'usuarios': 2,
      });
      expect(r.permisos, {'pagos.validar'});
      expect(r.requiereCafeteria, isTrue);
      expect(r.sePuedeEliminar, isFalse);
      expect(r.esDeSistema, isFalse);
    });
  });

  group('el administrador maneja roles', () {
    test('crea un rol, le da permisos y entonces pide cafetería', () async {
      final vm = AdminViewModel(MockAdminRepository());
      await _esperar();
      expect(vm.roles.map((r) => r.nombre),
          containsAll(['admin', 'alumno', 'empleado', 'encargado']));
      expect(vm.permisos, hasLength(Permisos.nombres.length));

      expect(vm.validarNombreRol('Cajero'), contains('minúsculas'));
      expect(
          vm.validarNombreRol('encargado'), 'Ya existe un rol con ese nombre.');
      expect(vm.validarNombreRol('cajero'), isNull);
      expect(await vm.crearRol('cajero', 'Cobra en caja'), isTrue);
      final cajero = vm.roles.firstWhere((r) => r.nombre == 'cajero');
      expect(cajero.permisos, isEmpty);
      expect(vm.necesitaCafeteria('cajero'), isFalse);

      expect(
          await vm.cambiarPermiso(cajero, Permisos.pagosValidar, true), isTrue);
      expect(vm.roles.firstWhere((r) => r.nombre == 'cajero').permisos,
          {Permisos.pagosValidar});
      expect(vm.necesitaCafeteria('cajero'), isTrue);
      expect(vm.validarAsignacion('nuevo@utng.edu.mx', 'cajero', null),
          'Elige la cafetería.');
      expect(await vm.asignarRol('nuevo@utng.edu.mx', 'cajero', 'c1'), isTrue);
      expect(vm.personal.single.etiqueta, 'Cajero');
    });

    test('no cambia permisos protegidos ni borra roles de sistema', () async {
      final vm = AdminViewModel(MockAdminRepository());
      await _esperar();
      final admin = vm.roles.firstWhere((r) => r.nombre == 'admin');
      expect(await vm.cambiarPermiso(admin, Permisos.adminGestionar, false),
          isFalse);
      expect(vm.roles.firstWhere((r) => r.nombre == 'admin').permisos,
          contains(Permisos.adminGestionar));
      final empleado = vm.roles.firstWhere((r) => r.nombre == 'empleado');
      expect(empleado.sePuedeEliminar, isFalse);
      expect(await vm.eliminarRol(empleado), isFalse);
      expect(vm.error, contains('rol de sistema'));

      await vm.crearRol('temporal', '');
      final temporal = vm.roles.firstWhere((r) => r.nombre == 'temporal');
      expect(await vm.eliminarRol(temporal), isTrue);
      expect(vm.roles.any((r) => r.nombre == 'temporal'), isFalse);
    });
  });
}
