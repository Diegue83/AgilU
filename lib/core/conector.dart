import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';

import '../dataconnect_generated/agilu.dart';

AgiluConnector? _conector;

/// Conexión única a SQL Connect para toda la app.
///
/// `AgiluConnector.instance` siempre crea Firebase App Check, que no tiene
/// implementación en Windows ni Linux y ahí lanza MissingPluginException. En
/// escritorio la conexión se arma sin App Check; en Android, iOS, macOS y web
/// se usa la del SDK.
AgiluConnector get conectorAgilu => _conector ??= _crear();

bool get _sinAppCheck =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux);

AgiluConnector _crear() {
  if (!_sinAppCheck) return AgiluConnector.instance;
  final app = Firebase.app();
  return AgiluConnector(
    // ignore: invalid_use_of_visible_for_testing_member
    dataConnect: FirebaseDataConnect(
      app: app,
      auth: FirebaseAuth.instanceFor(app: app),
      connectorConfig: AgiluConnector.connectorConfig,
      sdkType: CallerSDKType.generated,
    ),
  );
}
