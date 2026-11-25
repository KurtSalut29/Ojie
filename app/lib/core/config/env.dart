/// App settings passed in at build time with
/// `flutter run --dart-define-from-file=../.env`.
///
/// Only public values belong here. Everything in that file is compiled into
/// the app, so server secrets must never be added to it.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const powerSyncUrl = String.fromEnvironment('POWERSYNC_URL');
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  /// Names of the settings that are empty, so the app can explain what is
  /// wrong instead of failing later.
  static List<String> get missing => [
    if (supabaseUrl.isEmpty) 'SUPABASE_URL',
    if (supabasePublishableKey.isEmpty) 'SUPABASE_ANON_KEY',
    if (powerSyncUrl.isEmpty) 'POWERSYNC_URL',
    if (googleWebClientId.isEmpty) 'GOOGLE_WEB_CLIENT_ID',
  ];
}
