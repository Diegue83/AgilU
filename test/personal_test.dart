import 'package:agilu/core/routes.dart';
import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/data/models/personal.dart';
import 'package:agilu/data/repositories/personal_repository.dart';
import 'package:agilu/ui/admin/admin_view_model.dart';
import 'package:agilu/ui/encargado/personal/personal_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

Perfil _perfil(RolUsuario rol, {String? cafeteriaId}) => Perfil(
    nombre: 'X', correo: 'x@utng.edu.mx', rol: rol, cafeteriaId: cafeteriaId);

Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  group('pantalla de inicio por rol', () {
    test('cada rol abre su pantalla', () {
      expect(Routes.inicioPara(null), Routes.menu);
      expect(Routes.inicioPara(_perfil(RolUsuario.alumno)), Routes.menu);
      expect(Routes.inicioPara(_perfil(RolUsuario.empleado, cafeteriaId: 'c1')),
          Routes.encargado);
      expect(
          Routes.inicioPara(_perfil(RolUsuario.encargado, cafeteriaId: 'c1')),
          Routes.encargado);
      expect(
          Routes.inicioPara(_perfil(RolUsuario.beneficiaria)), Routes.reporte);
      expect(Routes.inicioPara(_perfil(RolUsuario.admin)), Routes.admin);
    });

    test('personal sin cafetería asignada entra como alumno', () {
      expect(Routes.inicioPara(_perfil(RolUsuario.empleado)), Routes.menu);
      expect(Routes.inicioPara(_perfil(RolUsuario.encargado)), Routes.menu);
    });

    test('un rol desconocido se trata como alumno', () {
      expect(RolUsuario.desdeNombre('superusuario'), RolUsuario.alumno);
      expect(RolUsuario.desdeNombre('empleado'), RolUsuario.empleado);
      expect(RolUsuario.desdeNombre('admin'), RolUsuario.admin);
    });
  });

  group('personal del encargado', () {
    test('valida el correo antes de enviarlo', () async {
      final vm = PersonalViewModel(MockPersonalRepository());
      await _esperar();
      expect(vm.validarCorreo(''), 'Escribe el correo de la persona.');
      expect(vm.validarCorreo('luis'), 'El correo no es válido.');
      expect(vm.validarCorreo('LUIS@utng.edu.mx'),
          'Esa persona ya forma parte del personal.');
      expect(vm.validarCorreo('nuevo@utng.edu.mx'), isNull);
    });

    test('agrega a un alumno registrado y lo puede quitar', () async {
      final repo = MockPersonalRepository();
      final vm = PersonalViewModel(repo);
      await _esperar();
      expect(await vm.agregar('nuevo@utng.edu.mx'), isTrue);
      final nuevo =
          vm.personal.firstWhere((p) => p.correo == 'nuevo@utng.edu.mx');
      expect(nuevo.rol, RolUsuario.empleado);

      expect(await vm.quitar(nuevo), isTrue);
      expect(vm.personal.any((p) => p.correo == 'nuevo@utng.edu.mx'), isFalse);
      expect(repo.alumnos, contains('nuevo@utng.edu.mx'));
    });

    test('una cuenta que no existe muestra el motivo', () async {
      final vm = PersonalViewModel(MockPersonalRepository());
      await _esperar();
      expect(await vm.agregar('nadie@utng.edu.mx'), isFalse);
      expect(vm.error, contains('debe registrarse primero'));
    });

    test('no se puede quitar al encargado', () async {
      final vm = PersonalViewModel(MockPersonalRepository());
      await _esperar();
      final encargado =
          vm.personal.firstWhere((p) => p.rol == RolUsuario.encargado);
      expect(await vm.quitar(encargado), isFalse);
      expect(vm.error, 'Esa persona no es empleado de tu cafetería.');
    });
  });

  group('administrador', () {
    test('crea una cafetería y no permite nombres repetidos', () async {
      final vm = AdminViewModel(MockAdminRepository());
      await _esperar();
      expect(
          vm.validarNombreCafeteria(' '), 'Escribe el nombre de la cafetería.');
      expect(vm.validarNombreCafeteria('cafetería CENTRAL'),
          'Ya existe una cafetería con ese nombre.');
      expect(await vm.crearCafeteria('Barra de café', 'Biblioteca'), isTrue);
      expect(vm.cafeterias.map((c) => c.nombre), contains('Barra de café'));
    });

    test('encargado y empleado necesitan cafetería; los demás no', () async {
      final vm = AdminViewModel(MockAdminRepository());
      await _esperar();
      expect(vm.validarAsignacion('a@utng.edu.mx', RolUsuario.empleado, null),
          'Elige la cafetería.');
      expect(
          vm.validarAsignacion('a@utng.edu.mx', RolUsuario.beneficiaria, null),
          isNull);
      expect(vm.validarAsignacion('correo', RolUsuario.admin, null),
          'El correo no es válido.');
    });

    test('asigna encargado de una cafetería y lo regresa a alumno', () async {
      final vm = AdminViewModel(MockAdminRepository());
      await _esperar();
      expect(
          await vm.asignarRol('nuevo@utng.edu.mx', RolUsuario.encargado, 'c1'),
          isTrue);
      expect(vm.personal.single.rol, RolUsuario.encargado);
      expect(vm.personal.single.cafeteria, 'Cafetería central');

      expect(await vm.asignarRol('nuevo@utng.edu.mx', RolUsuario.alumno, 'c1'),
          isTrue);
      expect(vm.personal, isEmpty);
    });

    test('no asigna en una cafetería inactiva', () async {
      final vm = AdminViewModel(MockAdminRepository());
      await _esperar();
      await vm.editarCafeteria(vm.cafeterias.first.copiar(activa: false));
      expect(vm.cafeteriasActivas, isEmpty);
      expect(
          await vm.asignarRol('nuevo@utng.edu.mx', RolUsuario.empleado, 'c1'),
          isFalse);
      expect(vm.error, contains('la cafetería esté activa'));
    });

    test('lee las filas de SQL nativo', () {
      final m = MiembroPersonal.desdeMapa({
        'usuarioId': 'u1',
        'nombre': 'Luis',
        'correo': 'luis@utng.edu.mx',
        'rol': 'empleado',
        'cafeteriaId': 'c1',
        'cafeteria': 'Central',
      });
      expect(m.rol, RolUsuario.empleado);
      expect(m.cafeteria, 'Central');
      final c = CafeteriaAdmin.desdeMapa({
        'id': 'c1',
        'nombre': 'Central',
        'ubicacion': null,
        'activa': false
      });
      expect(c.activa, isFalse);
      expect(etiquetaRol(RolUsuario.admin), 'Administrador');
    });
  });
}
