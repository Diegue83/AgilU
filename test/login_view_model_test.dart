import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/firebase_auth_repository.dart';
import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/ui/auth/login_view_model.dart';
import 'package:agilu/ui/auth/registro_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuthQueFalla extends MockAuthRepository {
  int llamadas = 0;

  @override
  Future<String> iniciarSesion(String correo, String contrasena) async {
    llamadas++;
    throw Exception('Correo o contraseña incorrectos.');
  }
}

void main() {
  test('rechaza campos vacíos sin llamar al repositorio', () async {
    final auth = _AuthQueFalla();
    final vm = LoginViewModel(auth);
    expect(await vm.enviar('', ''), isFalse);
    expect(vm.error, 'Escribe tu correo y tu contraseña.');
    expect(auth.llamadas, 0);
  });

  test('rechaza un correo con formato inválido', () async {
    final vm = LoginViewModel(MockAuthRepository());
    expect(await vm.enviar('alumno@utng', '123456'), isFalse);
    expect(vm.error, 'El correo no tiene un formato válido.');
  });

  test('el nombre de cuentas viejas sale del correo', () {
    expect(FirebaseAuthRepository.nombreDesdeCorreo('ana.lopez@utng.edu.mx'),
        'ana.lopez');
  });

  test('inicia sesión con datos válidos y recorta espacios', () async {
    final auth = MockAuthRepository();
    final vm = LoginViewModel(auth);
    expect(await vm.enviar('  alumno@utng.edu.mx ', '123456'), isTrue);
    expect(vm.error, isNull);
    expect(vm.cargando, isFalse);
    expect(auth.uidActual, isNotNull);
  });

  test('muestra el mensaje del repositorio cuando falla', () async {
    final vm = LoginViewModel(_AuthQueFalla());
    expect(await vm.enviar('alumno@utng.edu.mx', 'equivocada'), isFalse);
    expect(vm.error, 'Correo o contraseña incorrectos.');
  });

  test('la sesión guardada se borra al cerrar sesión', () async {
    final auth = MockAuthRepository();
    await auth.iniciarSesion('alumno@utng.edu.mx', '123456');
    expect(await auth.sesionGuardada(), isNotNull);
    await auth.cerrarSesion();
    expect(await auth.sesionGuardada(), isNull);
  });

  test('traduce los códigos de Firebase Auth', () {
    expect(FirebaseAuthRepository.mensajeDeError('invalid-credential'),
        'Correo o contraseña incorrectos.');
    expect(FirebaseAuthRepository.mensajeDeError('email-already-in-use'),
        'Ya existe una cuenta con ese correo. Inicia sesión.');
    expect(FirebaseAuthRepository.mensajeDeError('network-request-failed'),
        'Sin conexión. Revisa tu internet e intenta de nuevo.');
    expect(FirebaseAuthRepository.mensajeDeError('codigo-desconocido'),
        'No se pudo completar la operación. Intenta de nuevo.');
  });

  group('registro por pasos', () {
    test('el primer paso pide nombre y apellidos válidos', () {
      final vm = RegistroViewModel(MockAuthRepository());
      expect(vm.validarDatos('', 'López', ''), 'Escribe tu nombre.');
      expect(vm.validarDatos('Ana', ' ', ''), 'Escribe tus apellidos.');
      expect(vm.validarDatos('Ana2', 'López', ''),
          'El nombre y los apellidos solo llevan letras.');
      expect(vm.validarDatos('Ana', 'López', '12345'),
          'El teléfono debe tener 10 dígitos.');
      expect(vm.validarDatos('Ana María', 'López Pérez', ''), isNull);
      expect(vm.validarDatos('Ana', 'López', '418 123-4567'), isNull);
    });

    test('no pasa al segundo paso con datos inválidos', () {
      final vm = RegistroViewModel(MockAuthRepository());
      expect(vm.continuar('', '', ''), isFalse);
      expect(vm.paso, 0);
      expect(vm.error, 'Escribe tu nombre.');
    });

    test('el segundo paso valida correo y que las contraseñas coincidan', () {
      final vm = RegistroViewModel(MockAuthRepository());
      expect(vm.validarCredenciales('ana@utng', '123456', '123456'),
          'El correo no tiene un formato válido.');
      expect(vm.validarCredenciales('ana@utng.edu.mx', '123', '123'),
          'La contraseña debe tener al menos 6 caracteres.');
      expect(vm.validarCredenciales('ana@utng.edu.mx', '123456', '123457'),
          'Las contraseñas no coinciden.');
      expect(vm.validarCredenciales('ana@utng.edu.mx', '123456', '123456'),
          isNull);
    });

    test('registra con los datos de ambos pasos', () async {
      final auth = MockAuthRepository();
      final vm = RegistroViewModel(auth);
      expect(vm.continuar(' Ana ', 'López', '(418) 123 4567'), isTrue);
      expect(vm.paso, 1);
      expect(
          await vm.registrar(' ana@utng.edu.mx ', '123456', '123456'), isTrue);
      expect(auth.uidActual, isNotNull);
      expect(auth.registrado?.nombreCompleto, 'Ana López');
      expect(auth.registrado?.telefono, '4181234567');
    });

    test('regresar al primer paso conserva el paso 1 sin error', () {
      final vm = RegistroViewModel(MockAuthRepository());
      vm.continuar('Ana', 'López', '');
      vm.regresar();
      expect(vm.paso, 0);
      expect(vm.error, isNull);
    });

    test('el nombre completo junta nombre y apellidos', () {
      const d = DatosPersonales(nombre: ' Ana ', apellidos: ' López ');
      expect(d.nombreCompleto, 'Ana López');
    });
  });
}
