/// Compile-time secrets injected with `--dart-define-from-file`.
///
/// **Setup (teammates)**
/// 1. Copy the example file once after cloning:
///    `cp api_keys.json.example api_keys.json`
/// 2. Put your real Google Maps API key in `api_keys.json`.
/// 3. Run / debug with the define file:
///    `flutter run --dart-define-from-file=api_keys.json`
///
/// `api_keys.json` is gitignored. Only the `.example` file is committed.
///
/// VS Code / Cursor: use the "loci" launch configs (they pass the same flag).
/// Codemagic: set `GOOGLE_MAPS_API_KEY` in the env group; builds pass
/// `--dart-define=GOOGLE_MAPS_API_KEY=...`.
class AppSecrets {
  AppSecrets._();

  /// Google Maps / Places client key baked in at compile time.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static bool get hasGoogleMapsApiKey => googleMapsApiKey.isNotEmpty;
}
