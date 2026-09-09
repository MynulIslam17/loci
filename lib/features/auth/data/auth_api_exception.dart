/// An auth request that failed with an HTTP status the caller needs to branch
/// on — currently only the Apple flow, which re-runs the native sheet on 401.
/// [toString] returns the already user-facing message from [NetworkCaller], so
/// `AppErrorMessages.sanitize` still produces safe copy for the UI.
class AuthApiException implements Exception {
  final int statusCode;
  final String message;

  AuthApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}
