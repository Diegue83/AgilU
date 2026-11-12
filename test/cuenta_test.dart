import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/data/repositories/perfil_repository.dart';
import 'package:agilu/ui/cuenta/cuenta_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  group('nivel de confianza', () {
    test('baja con cada pedido sin recoger hasta bloquear', () {
      expect(NivelConfianza.para(0, limite: 3), NivelConfianza.excelente);
      expect(NivelConfianza.para(1, limite: 3), NivelConfianza.buena);
      expect(NivelConfianza.para(2, limite: 3), NivelConfianza.enRiesgo);
      expect(NivelConfianza.para(3, limite: 3), NivelConfianza.bloqueado);
      expect(NivelConfianza.para(5, limite: 3), NivelConfianza.bloqueado);
    });

    test('la cuenta del alumno carga su perfil y sus no recogidos', () async {
      final vm = CuentaViewModel(MockPerfilRepository(), MockAuthRepository(),
          MockPedidoRepository()..sinRecoger = 2);
      await _esperar();
      expect(vm.perfil?.nombre, 'Alumno demo');
      expect(vm.noRecogidos, 2);
      expect(vm.confianza, NivelConfianza.enRiesgo);
    });

    test('al personal no se le calcula la confianza', () async {
      final vm = CuentaViewModel(
          MockPerfilRepository(
              perfil: const Perfil(
                  nombre: 'Beto',
                  correo: 'beto@utng.edu.mx',
                  rol: RolUsuario.encargado,
                  cafeteriaId: 'c1')),
          MockAuthRepository(),
          MockPedidoRepository()..sinRecoger = 3);
      await _esperar();
      expect(vm.esAlumno, isFalse);
      expect(vm.noRecogidos, 0);
    });
  });

  group('datos y seguridad', () {
    test('edita nombre y teléfono con validación', () async {
      final vm = CuentaViewModel(
          MockPerfilRepository(), MockAuthRepository(), MockPedidoRepository());
      await _esperar();
      expect(vm.validarDatos('A', ''), 'Escribe tu nombre completo.');
      expect(vm.validarDatos('Ana López', '123'),
          'El teléfono debe tener 10 dígitos.');
      expect(await vm.editarDatos(' Ana López ', '418 123 4567'), isTrue);
      expect(vm.perfil?.nombre, 'Ana López');
      expect(vm.perfil?.telefono, '4181234567');
    });

    test('cambiar la contraseña pide la actual correcta', () async {
      final auth = MockAuthRepository();
      final vm =
          CuentaViewModel(MockPerfilRepository(), auth, MockPedidoRepository());
      await _esperar();
      expect(vm.validarContrasena('123', '123'),
          'La contraseña debe tener al menos 6 caracteres.');
      expect(vm.validarContrasena('abcdef', 'abcdeg'),
          'Las contraseñas no coinciden.');
      expect(await vm.cambiarContrasena('equivocada', 'nueva123'), isFalse);
      expect(vm.error, 'La contraseña actual no es correcta.');
      expect(await vm.cambiarContrasena('123456', 'nueva123'), isTrue);
      expect(auth.contrasena, 'nueva123');
    });

    test('eliminar la cuenta borra datos y acceso', () async {
      final auth = MockAuthRepository();
      final perfiles = MockPerfilRepository();
      final vm = CuentaViewModel(perfiles, auth, MockPedidoRepository());
      await _esperar();
      expect(await vm.eliminarCuenta('123456'), isTrue);
      expect(perfiles.eliminado, isTrue);
      expect(auth.eliminada, isTrue);
    });

    test('si el servidor la rechaza, la cuenta de acceso no se borra',
        () async {
      final auth = MockAuthRepository();
      final perfiles = MockPerfilRepository()..permitirBaja = false;
      final vm = CuentaViewModel(perfiles, auth, MockPedidoRepository());
      await _esperar();
      expect(await vm.eliminarCuenta('123456'), isFalse);
      expect(vm.error, contains('pedidos en curso'));
      expect(auth.eliminada, isFalse);
    });

    test('con contraseña equivocada no se borra nada', () async {
      final auth = MockAuthRepository();
      final perfiles = MockPerfilRepository();
      final vm = CuentaViewModel(perfiles, auth, MockPedidoRepository());
      await _esperar();
      expect(await vm.eliminarCuenta('otra'), isFalse);
      expect(perfiles.eliminado, isFalse);
      expect(auth.eliminada, isFalse);
    });
  });
}
