/// Configuración global de la app.
class AppConfig {
  /// false = la app corre con datos de ejemplo (sin Firebase).
  /// true  = usa Firebase Authentication + SQL Connect.
  static const bool usarFirebase = true;

  /// Conecta Auth y SQL Connect a los emuladores locales:
  /// flutter run --dart-define=EMULADORES=true
  static const bool usarEmuladores = bool.fromEnvironment('EMULADORES');

  /// Host de los servicios locales de Firebase. En Android, los SDK de Firebase
  /// cambian "localhost" y "127.0.0.1" por 10.0.2.2, que solo existe en la
  /// máquina virtual de Android Studio. En un teléfono conectado por USB usa
  /// `adb reverse` y --dart-define=FIREBASE_HOST=127.0.0.2
  static const String hostFirebaseLocal =
      String.fromEnvironment('FIREBASE_HOST', defaultValue: 'localhost');
  static const String cafeteriaPorDefecto = 'cafeteria-central';

  /// Supabase Storage para comprobantes y fotos de productos. Son valores
  /// públicos del proyecto de Supabase (URL y llave publicable), no secretos;
  /// los permisos los dan las políticas de supabase/almacenamiento.sql.
  /// --dart-define=SUPABASE_URL=https://<ref>.supabase.co
  /// --dart-define=SUPABASE_KEY=<llave publicable>
  /// Sin ellos, comprobantes y fotos usan las Cloud Functions.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseKey = String.fromEnvironment('SUPABASE_KEY');
  static bool get usarSupabase =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  /// HU-23: pedidos sin recoger en 30 días que bloquean nuevos pedidos.
  /// Debe coincidir con CrearPedido en dataconnect/agilu/mutations.gql.
  static const int limiteNoRecogidos = 3;
  static const int anticipacionMinutos = 60; // regla del beneficiario
  static const int intervaloRecogidaMinutos = 15;
  static const int aperturaMinutos = 7 * 60 + 30; // 07:30
  static const int cierreMinutos = 23 * 60; // cambiar a la hora sugerida
}
