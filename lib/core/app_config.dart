/// Configuración global de la app.
class AppConfig {
  /// false = la app corre con datos de ejemplo (sin Firebase).
  /// true  = usa Firebase Authentication + Cloud Firestore.
  /// Cambiar a true cuando Juan Diego termine la configuración de Firebase.
  static const bool usarFirebase = false;
}
