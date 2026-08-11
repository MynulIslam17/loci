import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loci/core/constants/google_auth_config.dart';

/// Native Google Sign-In (v7: initialize + authenticate).
///
/// Returns an OpenID [idToken] for `POST /auth/google` — never the access token.
class GoogleSignInService {
  GoogleSignInService();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    if (_isIos && !GoogleAuthConfig.isIosClientConfigured) {
      throw Exception(
        'iOS Google client ID is not configured. '
        'Set GoogleAuthConfig.iosClientId and Info.plist GIDClientID / URL scheme.',
      );
    }

    await _googleSignIn.initialize(
      clientId: _isIos ? GoogleAuthConfig.iosClientId : null,
      serverClientId: GoogleAuthConfig.serverClientId,
    );
    _initialized = true;
  }

  /// Interactive Google sign-in.
  ///
  /// Returns `null` if the user cancels. Throws if [idToken] is missing
  /// (usually wrong/missing [serverClientId] or platform OAuth client).
  Future<String?> getIdToken() async {
    await _ensureInitialized();

    try {
      final account = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile', 'openid'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Google idToken was null. Check serverClientId and the '
          '${_isIos ? 'iOS' : 'Android'} OAuth client in Google Cloud.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted ||
          e.code == GoogleSignInExceptionCode.uiUnavailable) {
        return null;
      }
      rethrow;
    }
  }

  /// Clears the Google session so the account picker shows again next time.
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
    } catch (e, st) {
      // Best-effort — app logout must still proceed.
      debugPrint('GoogleSignIn.signOut failed: $e\n$st');
    }
  }
}
