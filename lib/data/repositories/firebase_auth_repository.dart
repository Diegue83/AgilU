import 'package:firebase_auth/firebase_auth.dart';

import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  String? get uidActual => _auth.currentUser?.uid;

  @override
  Future<String> iniciarSesion(String correo, String contrasena) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: correo, password: contrasena);
    return cred.user!.uid;
  }

  @override
  Future<String> registrar(String correo, String contrasena) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: correo, password: contrasena);
    return cred.user!.uid;
  }

  @override
  Future<void> cerrarSesion() => _auth.signOut();
}
