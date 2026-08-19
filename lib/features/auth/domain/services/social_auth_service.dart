import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Handles platform-specific social authentication SDK interactions
/// for Google Sign-In and Sign-In with Apple.
class SocialAuthService {
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

  /// Signs in with Apple and returns the identityToken.
  /// Returns `null` if the user cancelled.
  Future<String?> getAppleIdentityToken() async {
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
      return identityToken;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null; // User cancelled
      }
      rethrow;
    }
  }
}
