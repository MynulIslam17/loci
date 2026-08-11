/// Google Sign-In OAuth IDs.
///
/// Swap these when the client hands over their Google Cloud project.
abstract class GoogleAuthConfig {
  /// Web client ID — always used as [serverClientId] (not Android/iOS).
  static const String serverClientId =
      '965450815025-1rhqr7srtc73ot384coira9emsndf9gc.apps.googleusercontent.com';

  /// iOS OAuth client ID from Google Cloud Console
  /// (type: iOS, bundle ID: `ui.neatboutique.jacobi`).
  ///
  /// Required for TestFlight / device builds. Without this + the matching
  /// reversed URL scheme in `ios/Runner/Info.plist`, the button crashes.
  ///
  /// Example: `123456789-abcdefg.apps.googleusercontent.com`
  static const String iosClientId =
      'REPLACE_WITH_IOS_CLIENT_ID.apps.googleusercontent.com';

  /// Reversed iOS client ID for `CFBundleURLSchemes` in Info.plist.
  /// Derived from [iosClientId] by dropping `.apps.googleusercontent.com`
  /// and prefixing `com.googleusercontent.apps.`.
  static String get iosReversedClientId {
    const suffix = '.apps.googleusercontent.com';
    if (!iosClientId.endsWith(suffix)) {
      throw StateError('Invalid iosClientId: expected *$suffix');
    }
    final id = iosClientId.substring(0, iosClientId.length - suffix.length);
    return 'com.googleusercontent.apps.$id';
  }

  static bool get isIosClientConfigured =>
      iosClientId.isNotEmpty &&
      !iosClientId.startsWith('REPLACE_WITH_IOS_CLIENT_ID');
}
