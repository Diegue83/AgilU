import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/firebase_auth_repository.dart';
import 'package:agilu/ui/auth/login_view_model.dart';
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

  test('en registro exige contraseña de al menos 6 caracteres', () async {
    final vm = LoginViewModel(MockAuthRepository())..alternarModo();
    expect(
        await vm.enviar('alumno@utng.edu.mx', '123', nombre: 'Ana'), isFalse);
    expect(vm.error, 'La contraseña debe tener al menos 6 caracteres.');
  });

  test('en registro exige el nombre', () async {
    final vm = LoginViewModel(MockAuthRepository())..alternarModo();
    expect(
        await vm.enviar('alumno@utng.edu.mx', '123456', nombre: '  '), isFalse);
    expect(vm.error, 'Escribe tu nombre.');
  });

  test('registra con nombre y datos válidos', () async {
    final auth = MockAuthRepository();
    final vm = LoginViewModel(auth)..alternarModo();
    expect(
        await vm.enviar('alumno@utng.edu.mx', '123456', nombre: 'Ana'), isTrue);
    expect(auth.uidActual, isNotNull);
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
}
