/// Configuración global de la app.
class AppConfig {
  /// false = la app corre con datos de ejemplo (sin Firebase).
  /// true  = usa Firebase Authentication + Cloud Firestore.
  /// Cambiar a true cuando Juan Diego termine la configuración de Firebase.
  static const bool usarFirebase = false;
  static const String cafeteriaPorDefecto = 'cafeteria-central';
  static const int anticipacionMinutos = 60;        // regla del beneficiario
  static const int intervaloRecogidaMinutos = 15;
  static const int aperturaMinutos = 7 * 60 + 30;   // 07:30
  static const int cierreMinutos = 23 * 60;         // cambiar a la hora sugerida
}
