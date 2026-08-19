import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:loci/features/auth/data/models/user_model.dart';

/// Secure & Synchronous Local Storage Service.
///
/// - Tokens (`_tokenKey`, `_refreshTokenKey`) are stored in hardware-encrypted
///   [FlutterSecureStorage] (Android Keystore / iOS Keychain).
/// - Non-sensitive UI data (`user-model`, `role`, `remember-me`) is stored in [SharedPreferences].
/// - [SharedPreferences] instance is injected to eliminate repeated `getInstance()` I/O disk calls.
class LocalStorageService {
  static const String _tokenKey = 'access-token';
  static const String _refreshTokenKey = 'refresh-token';
  static const String _userDataKey = 'user-model';
  static const String _roleKey = 'role';
  static const String _providerTypeKey = 'providerType';
  static const String _rememberMeKey = 'remember-me';
  static const String _rememberedEmailKey = 'remembered-email';

  final SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage;

  LocalStorageService({
    SharedPreferences? prefs,
    FlutterSecureStorage? secureStorage,
  })  : _prefs = prefs,
        _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs != null) return _prefs;
    return SharedPreferences.getInstance();
  }

  // ---------------------------------------------------------------------------
  // Secure Tokens (Hardware Encrypted)
  // ---------------------------------------------------------------------------

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  // ---------------------------------------------------------------------------
  // Profile & Role (SharedPreferences)
  // ---------------------------------------------------------------------------

  Future<void> saveUserModel(UserModel model) async {
    final prefs = await _getPrefs();
    await prefs.setString(_userDataKey, jsonEncode(model.toJson()));
    await prefs.setString(_roleKey, model.role);
  }

  Future<UserModel?> getUserModel() async {
    final prefs = await _getPrefs();
    final userJson = prefs.getString(_userDataKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  UserModel? getUserModelSync() {
    if (_prefs == null) return null;
    final userJson = _prefs.getString(_userDataKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<String?> getRole() async {
    final prefs = await _getPrefs();
    return prefs.getString(_roleKey);
  }

  String? getRoleSync() {
    return _prefs?.getString(_roleKey);
  }

  // ---------------------------------------------------------------------------
  // Remember Me
  // ---------------------------------------------------------------------------

  Future<void> saveRememberMe({required bool remember, String? email}) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_rememberMeKey, remember);
    if (remember && email != null && email.trim().isNotEmpty) {
      await prefs.setString(_rememberedEmailKey, email.trim());
    } else {
      await prefs.remove(_rememberedEmailKey);
    }
  }

  Future<({bool remember, String? email})> getRememberMe() async {
    final prefs = await _getPrefs();
    final remember = prefs.getBool(_rememberMeKey) ?? false;
    final email = prefs.getString(_rememberedEmailKey);
    return (remember: remember, email: email);
  }

  ({bool remember, String? email}) getRememberMeSync() {
    if (_prefs == null) return (remember: false, email: null);
    final remember = _prefs.getBool(_rememberMeKey) ?? false;
    final email = _prefs.getString(_rememberedEmailKey);
    return (remember: remember, email: email);
  }

  // ---------------------------------------------------------------------------
  // Clear Auth / Session (Preserves Remember Me Email on Logout)
  // ---------------------------------------------------------------------------

  /// Clears active user tokens and session profile while keeping remembered email intact.
  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);

    final prefs = await _getPrefs();
    await prefs.remove(_userDataKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_providerTypeKey);
  }

  /// Wipes all local preferences and secure storage completely.
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await _getPrefs();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_providerTypeKey);
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_rememberedEmailKey);
  }
}
