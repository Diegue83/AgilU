/// Configuración global de la app.
class AppConfig {
  /// false = la app corre con datos de ejemplo (sin Firebase).
  /// true  = usa Firebase Authentication + SQL Connect.
  static const bool usarFirebase = true;

  /// Conecta Auth y SQL Connect a los emuladores locales:
  /// flutter run --dart-define=EMULADORES=true
  static const bool usarEmuladores = bool.fromEnvironment('EMULADORES');
  static const String cafeteriaPorDefecto = 'cafeteria-central';
  static const int anticipacionMinutos = 60;        // regla del beneficiario
  static const int intervaloRecogidaMinutos = 15;
  static const int aperturaMinutos = 7 * 60 + 30;   // 07:30
  static const int cierreMinutos = 23 * 60;         // cambiar a la hora sugerida
}
