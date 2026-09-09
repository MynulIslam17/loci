import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// A completed Sign-In with Apple authorization. [fullName] is null on every
/// authorization after the user's first one — see [getAppleCredential].
typedef AppleCredential = ({String identityToken, String? fullName});

/// Handles platform-specific social authentication SDK interactions
/// for Google Sign-In and Sign-In with Apple.
class SocialAuthService {
  /// Sign in with Apple is offered on iOS only. The Services ID needed for the
  /// browser-redirect flow is deliberately not configured, so Android and web
  /// would always get a 401 back; Google Sign-In covers them instead.
  static bool get isAppleSignInSupported => !kIsWeb && Platform.isIOS;

  static const String iosClientId =
      '339606588573-nf9lhkj2qo4555mt7j4rmr4hjhllrb34.apps.googleusercontent.com';
  static const String webClientId =
      '339606588573-ne1qjf5jbgsn90f6q5rjq6m3ouj652dn.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: !kIsWeb && Platform.isIOS ? iosClientId : null,
    serverClientId: webClientId,
    scopes: ['email', 'profile'],
  );

  /// Signs in with Google and returns the idToken.
  /// Returns `null` if the user cancelled the sign-in prompt.
  Future<String?> getGoogleIdToken() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    final account = await _googleSignIn.signIn();
    if (account == null) {
      return null; // User cancelled
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to retrieve Google ID token.');
    }
    return idToken;
  }

  /// Signs in with Apple. Returns `null` if the user cancelled.
  ///
  /// Apple hands over givenName/familyName only on the user's very first
  /// authorization for this app and never again — not on re-login, not after
  /// the token expires. Dropping it here makes the backend fall back to the
  /// email local-part, and that name is then permanently wrong for the user.
  Future<AppleCredential?> getAppleCredential() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw Exception('Failed to retrieve Apple identity token.');
      }

      final fullName = [credential.givenName, credential.familyName]
          .whereType<String>()
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .join(' ');

      return (
        identityToken: identityToken,
        fullName: fullName.isEmpty ? null : fullName,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null; // User cancelled
      }
      rethrow;
    }
  }
}
