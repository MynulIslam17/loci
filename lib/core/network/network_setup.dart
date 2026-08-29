import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/storage/local_storage_service.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/routes/app_routes.dart';

import 'package:logger/logger.dart';

import 'network_caller.dart';

final Logger _logger = Logger();

NetworkCaller setUpNetworkClient() {
  return NetworkCaller(
    onUnAuthorize: _onUnAuthorize,
    accessToken: _readAccessToken,
    onRefreshToken: _handleRefreshToken,
  );
}

String _readAccessToken() {
  if (!Get.isRegistered<AuthController>()) return '';
  return Get.find<AuthController>().accessToken ?? '';
}

Completer<bool>? _refreshCompleter;

/// Attempt to refresh token using saved refreshToken.
/// Uses a Completer so concurrent 401s queue behind a single network call.
Future<bool> _handleRefreshToken() async {
  if (_refreshCompleter != null) {
    _logger.i('🔄 Concurrent 401 detected — waiting for active token refresh...');
    return _refreshCompleter!.future;
  }

  _refreshCompleter = Completer<bool>();

  try {
    if (!Get.isRegistered<LocalStorageService>()) {
      _logger.w('⚠️ LocalStorageService not registered during token refresh.');
      _refreshCompleter!.complete(false);
      return false;
    }

    final storage = Get.find<LocalStorageService>();
    final refreshToken = await storage.getRefreshToken();

    if (refreshToken == null || refreshToken.trim().isEmpty) {
      _logger.w('⚠️ No refreshToken found in LocalStorageService.');
      _refreshCompleter!.complete(false);
      return false;
    }

    _logger.i('''
================== REFRESH TOKEN REQUEST ===========
URL     : ${AppUrl.refreshToken}
TOKEN   : ${refreshToken.substring(0, refreshToken.length > 20 ? 20 : refreshToken.length)}...
====================================================''');

    // Direct HTTP POST to avoid recursing into NetworkCaller
    final url = Uri.parse(AppUrl.refreshToken);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken.trim()}),
    ).timeout(const Duration(seconds: 15));

    _logger.i('''
================== REFRESH TOKEN RESPONSE ==========
STATUS  : ${response.statusCode}
BODY    : ${response.body}
====================================================''');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];
      if (data is Map) {
        final newAccessToken =
            (data['accessToken'] ?? data['token'])?.toString();
        final newRefreshToken = data['refreshToken']?.toString();

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await storage.saveToken(newAccessToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await storage.saveRefreshToken(newRefreshToken);
          }
          if (Get.isRegistered<AuthController>()) {
            Get.find<AuthController>().accessTokenRx.value = newAccessToken;
          }
          _logger.i('✅ Token refreshed successfully! New access token applied.');
          _refreshCompleter!.complete(true);
          return true;
        }
      }
    }

    _logger.e('❌ Token refresh failed with status: ${response.statusCode}');
    _refreshCompleter!.complete(false);
    return false;
  } catch (e) {
    _logger.e('❌ Token refresh exception: $e');
    _refreshCompleter?.complete(false);
    return false;
  } finally {
    _refreshCompleter = null;
  }
}

/// Fires on any 401 when token refresh fails. Clears session and redirects.
bool _isHandlingUnauthorized = false;

Future<void> _onUnAuthorize() async {
  if (_isHandlingUnauthorized) return;
  _isHandlingUnauthorized = true;
  try {
    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().logout();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  } finally {
    _isHandlingUnauthorized = false;
  }
}
