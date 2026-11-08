import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../dataconnect_generated/agilu.dart';

/// HU-05: registra el dispositivo para recibir el aviso "pedido listo".
abstract class AvisosRepository {
  /// Pide permiso de notificaciones y guarda el token del dispositivo.
  Future<void> registrar();

  /// Deja de enviar avisos de esta cuenta a este dispositivo.
  Future<void> olvidar();

  /// Avisos que llegan con la app abierta.
  Stream<String> get enPrimerPlano;
}

/// Solo Android, iOS y web tienen notificaciones push; en escritorio no hace nada.
bool get pushDisponible =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

class FcmAvisosRepository implements AvisosRepository {
  final AgiluConnector _conector;
  FcmAvisosRepository({AgiluConnector? conector})
      : _conector = conector ?? AgiluConnector.instance;

  String get _plataforma => kIsWeb
      ? 'web'
      : defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : 'android';

  @override
  Future<void> registrar() async {
    if (!pushDisponible) return;
    final fcm = FirebaseMessaging.instance;
    final permiso = await fcm.requestPermission();
    if (permiso.authorizationStatus == AuthorizationStatus.denied) return;
    final token = await fcm.getToken();
    if (token == null) return;
    await _conector
        .registrarDispositivo(token: token, plataforma: _plataforma)
        .execute();
    fcm.onTokenRefresh.listen((nuevo) => _conector
        .registrarDispositivo(token: nuevo, plataforma: _plataforma)
        .execute());
  }

  @override
  Future<void> olvidar() async {
    if (!pushDisponible) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _conector.olvidarDispositivo(token: token).execute();
    }
  }

  @override
  Stream<String> get enPrimerPlano => pushDisponible
      ? FirebaseMessaging.onMessage
          .map((m) => m.notification?.body ?? '')
          .where((t) => t.isNotEmpty)
      : const Stream.empty();
}

class MockAvisosRepository implements AvisosRepository {
  bool registrado = false;

  @override
  Future<void> registrar() async => registrado = true;

  @override
  Future<void> olvidar() async => registrado = false;

  @override
  Stream<String> get enPrimerPlano => const Stream.empty();
}
