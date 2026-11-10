// Ejemplo de lib/firebase_options.dart con valores FICTICIOS.
//
// El archivo real lo genera cada integrante con:
//   flutterfire configure --project=agilu-a232a
// y está en .gitignore. Este ejemplo solo sirve para compilar y correr las
// pruebas en CI, que no se conectan a Firebase.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return _ejemplo;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.windows:
        return _ejemplo;
      default:
        throw UnsupportedError('Plataforma sin configuración de Firebase.');
    }
  }

  static const FirebaseOptions _ejemplo = FirebaseOptions(
    apiKey: 'TU_API_KEY_AQUI',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-agilu',
    storageBucket: 'demo-agilu.appspot.com',
  );
}
