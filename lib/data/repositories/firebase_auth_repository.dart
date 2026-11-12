import 'package:firebase_auth/firebase_auth.dart';

import '../models/perfil.dart';
import 'auth_repository.dart';
import 'perfil_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final PerfilRepository? _perfil;
  FirebaseAuthRepository({FirebaseAuth? auth, PerfilRepository? perfil})
      : _auth = auth ?? FirebaseAuth.instance,
        _perfil = perfil;

  @override
  String? get uidActual => _auth.currentUser?.uid;

  @override
  Future<String?> sesionGuardada() async =>
      (await _auth.authStateChanges().first)?.uid;

  @override
  Future<String> iniciarSesion(String correo, String contrasena) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: correo, password: contrasena);
      await _asegurarPerfil(nombreDesdeCorreo(correo));
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw Exception(mensajeDeError(e.code));
    }
  }

  @override
  Future<String> registrar(
      String correo, String contrasena, DatosPersonales datos) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: correo, password: contrasena);
      await _asegurarPerfil(datos.nombreCompleto, telefono: datos.telefono);
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw Exception(mensajeDeError(e.code));
    }
  }

  Future<void> _asegurarPerfil(String nombre, {String? telefono}) async {
    if (_perfil == null) return;
    try {
      await _perfil.asegurarPerfil(nombre, telefono: telefono);
    } catch (_) {
      throw Exception(
          'Tu cuenta está lista, pero no se pudo crear tu perfil. Inicia sesión de nuevo.');
    }
  }

  /// Para cuentas creadas antes de que existiera el perfil.
  static String nombreDesdeCorreo(String correo) => correo.split('@').first;

  @override
  Future<void> cerrarSesion() => _auth.signOut();

  User get _usuario {
    final u = _auth.currentUser;
    if (u == null) {
      throw Exception('Tu sesión terminó. Inicia sesión de nuevo.');
    }
    return u;
  }

  @override
  Future<void> reautenticar(String contrasena) async {
    final u = _usuario;
    try {
      await u.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: u.email!, password: contrasena));
    } on FirebaseAuthException catch (e) {
      throw Exception(
          e.code == 'wrong-password' || e.code == 'invalid-credential'
              ? 'La contraseña actual no es correcta.'
              : mensajeDeError(e.code));
    }
  }

  @override
  Future<void> cambiarContrasena(String actual, String nueva) async {
    await reautenticar(actual);
    try {
      await _usuario.updatePassword(nueva);
    } on FirebaseAuthException catch (e) {
      throw Exception(mensajeDeError(e.code));
    }
  }

  @override
  Future<void> eliminarCuentaActual() async {
    try {
      await _usuario.delete();
    } on FirebaseAuthException catch (e) {
      throw Exception(mensajeDeError(e.code));
    }
  }

  /// Traduce los códigos de FirebaseAuthException a mensajes para el alumno.
  static String mensajeDeError(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada. Acude a la cafetería.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo. Inicia sesión.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos e intenta de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión. Revisa tu internet e intenta de nuevo.';
      case 'requires-recent-login':
        return 'Por seguridad, vuelve a escribir tu contraseña.';
      case 'operation-not-allowed':
        return 'El registro con correo no está habilitado.';
      default:
        return 'No se pudo completar la operación. Intenta de nuevo.';
    }
  }
}
