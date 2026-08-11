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

  bool _isReauthFailure(GoogleSignInException e) {
    final desc = (e.description ?? '').toLowerCase();
    return desc.contains('account reauth failed') || desc.contains('[16]');
  }

  bool _isUserCancel(GoogleSignInException e) {
    return e.code == GoogleSignInExceptionCode.canceled && !_isReauthFailure(e);
  }

  Future<String> _authenticateForIdToken() async {
    final account = await _googleSignIn.authenticate(
      scopeHint: const ['email', 'profile', 'openid'],
    );
    final idToken = account.authentication.idToken;
    debugPrint(
      'GoogleSignIn: account=${account.email}, '
      'idTokenLen=${idToken?.length ?? 0}',
    );
    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google idToken was null. Check serverClientId and the '
        '${_isIos ? 'iOS' : 'Android'} OAuth client in Google Cloud '
        '(package/bundle + SHA-1).',
      );
    }
    return idToken;
  }

  Future<void> _clearGoogleSession() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      try {
        await _googleSignIn.signOut();
      } catch (e, st) {
        debugPrint('GoogleSignIn clear session failed: $e\n$st');
      }
    }
  }

  /// Interactive Google sign-in.
  ///
  /// Returns `null` if the user cancels. Throws if [idToken] is missing
  /// (usually wrong/missing [serverClientId] or platform OAuth client).
  Future<String?> getIdToken() async {
    await _ensureInitialized();

    try {
      return await _authenticateForIdToken();
    } on GoogleSignInException catch (e) {
      debugPrint(
        'GoogleSignInException: code=${e.code.name}, '
        'description=${e.description}',
      );

      if (_isUserCancel(e)) return null;

      // Stale Credential Manager session → clear and force a fresh picker.
      if (_isReauthFailure(e)) {
        debugPrint('GoogleSignIn: clearing stale session and retrying…');
        await _clearGoogleSession();
        try {
          return await _authenticateForIdToken();
        } on GoogleSignInException catch (e2) {
          debugPrint(
            'GoogleSignInException (retry): code=${e2.code.name}, '
            'description=${e2.description}',
          );
          if (_isUserCancel(e2)) return null;
          throw Exception(
            'Google Sign-In failed (${e2.code.name}): '
            '${e2.description ?? 'Account reauth failed. '
                'Add Android SHA-1 + package in Google Cloud, then try again.'}',
          );
        }
      }

      throw Exception(
        'Google Sign-In failed (${e.code.name}): '
        '${e.description ?? 'Check Android SHA-1 / package or iOS client ID '
            'in Google Cloud Console.'}',
      );
    } catch (e, st) {
      debugPrint('GoogleSignIn unexpected error: $e\n$st');
      rethrow;
    }
  }

  /// Clears the Google session so the account picker shows again next time.
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _clearGoogleSession();
    } catch (e, st) {
      // Best-effort — app logout must still proceed.
      debugPrint('GoogleSignIn.signOut failed: $e\n$st');
    }
  }
}
