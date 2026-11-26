import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../core/conector.dart';
import '../../dataconnect_generated/agilu.dart';

/// HU-05: registra el dispositivo para recibir el aviso "pedido listo".
abstract class AvisosRepository {
  /// Pide permiso de notificaciones y guarda el token del dispositivo.
  Future<void> registrar();

  /// Deja de enviar avisos de esta cuenta a este dispositivo.
  Future<void> olvidar();

  /// Avisos que llegan con la app abierta.
  Stream<String> get enPrimerPlano;

  /// Avisos que el usuario tocó en la barra de notificaciones (también el que
  /// abrió la app estando cerrada).
  Stream<AvisoAbierto> get abiertos;
}

/// A dónde lleva tocar un aviso.
enum DestinoAviso { ticket, panel, ninguno }

/// Datos que trae el push: el evento y el pedido.
class AvisoAbierto {
  final String? evento;
  final String? pedidoId;
  const AvisoAbierto({this.evento, this.pedidoId});

  /// Las versiones anteriores mandaban "tipo" en lugar de "evento".
  factory AvisoAbierto.desdeDatos(Map<String, dynamic> datos) => AvisoAbierto(
        evento: (datos['evento'] ?? datos['tipo']) as String?,
        pedidoId: datos['pedidoId'] as String?,
      );

  /// Los avisos del alumno abren su ticket; los del personal, su panel.
  DestinoAviso get destino => switch (evento) {
        'pago_validado' ||
        'pago_rechazado' ||
        'pedido_listo' when pedidoId != null =>
          DestinoAviso.ticket,
        'comprobante' || 'solicitud' => DestinoAviso.panel,
        _ => DestinoAviso.ninguno,
      };
}

/// Solo Android, iOS y web tienen notificaciones push; en escritorio no hace nada.
bool get pushDisponible =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

class FcmAvisosRepository implements AvisosRepository {
  final AgiluConnector _conector;
  FcmAvisosRepository({AgiluConnector? conector})
      : _conector = conector ?? conectorAgilu;

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

  @override
  Stream<AvisoAbierto> get abiertos {
    if (!pushDisponible) return const Stream.empty();
    final salida = StreamController<AvisoAbierto>();
    FirebaseMessaging.instance.getInitialMessage().then((m) {
      if (m != null && !salida.isClosed) {
        salida.add(AvisoAbierto.desdeDatos(m.data));
      }
    }, onError: (Object _) {});
    final sub = FirebaseMessaging.onMessageOpenedApp
        .listen((m) => salida.add(AvisoAbierto.desdeDatos(m.data)));
    salida.onCancel = () async {
      await sub.cancel();
      await salida.close();
    };
    return salida.stream;
  }
}

class MockAvisosRepository implements AvisosRepository {
  bool registrado = false;

  @override
  Future<void> registrar() async => registrado = true;

  @override
  Future<void> olvidar() async => registrado = false;

  @override
  Stream<String> get enPrimerPlano => const Stream.empty();

  final _abiertos = StreamController<AvisoAbierto>.broadcast();

  /// Simula que el usuario toca una notificación.
  void abrir(AvisoAbierto aviso) => _abiertos.add(aviso);

  @override
  Stream<AvisoAbierto> get abiertos => _abiertos.stream;
}
