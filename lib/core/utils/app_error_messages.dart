import 'package:flutter/material.dart';

/// Central, user-facing copy for network and app failures.
///
/// Use this everywhere errors reach the UI (snackbars, full-screen states,
/// inline banners) so 502 / HTML / FormatException noise never leaks through.
class AppErrorMessages {
  AppErrorMessages._();

  static const String generic = 'Something went wrong. Please try again.';
  static const String noInternet =
      'No internet connection. Please check your network.';
  static const String timeout =
      'Request timed out. Please check your connection.';
  static const String network = 'Network error. Please try again.';
  static const String serverUnavailable =
      "We're having trouble reaching the server. Please try again in a moment.";
  static const String sessionExpired = 'Session expired. Please log in again.';
  static const String forbidden =
      "You don't have permission to perform this action.";
  static const String notFound = 'The requested resource was not found.';
  static const String tooManyRequests =
      'Too many requests. Please wait a moment and try again.';
  static const String validation =
      'Invalid data submitted. Please review your input.';

  static const String defaultTitle = 'Something went wrong';
  static const String serverTitle = "Couldn't reach the server";
  static const String offlineTitle = "You're offline";

  /// Maps an HTTP status code to friendly copy.
  /// Prefer a clean [serverMessage] for client errors; never surface raw
  /// gateway HTML / "error code: 502" strings.
  static String forStatusCode(int statusCode, {String? serverMessage}) {
    final cleaned = _cleanServerMessage(serverMessage);

    switch (statusCode) {
      case 400:
        return cleaned ?? 'Bad request. Please check your input.';
      case 401:
        return cleaned ?? sessionExpired;
      case 403:
        return cleaned ?? forbidden;
      case 404:
        return cleaned ?? notFound;
      case 408:
        return cleaned ?? timeout;
      case 409:
        return cleaned ?? 'Conflict. This resource already exists.';
      case 422:
        return cleaned ?? validation;
      case 429:
        return cleaned ?? tooManyRequests;
      case 500:
      case 502:
      case 503:
      case 504:
        // Never prefer raw gateway bodies for 5xx — they're rarely useful.
        return serverUnavailable;
      default:
        if (statusCode >= 500) return serverUnavailable;
        return cleaned ?? generic;
    }
  }

  /// Title paired with [forStatusCode] / [sanitize] for full-screen states.
  static String titleFor({int? statusCode, String? message}) {
    if (statusCode == 401) return 'Session expired';
    if (statusCode != null && statusCode >= 500) return serverTitle;

    final text = (message ?? '').toLowerCase();
    if (text.contains('internet') || text.contains('offline')) {
      return offlineTitle;
    }
    if (text.contains('server') || text.contains('trouble reaching')) {
      return serverTitle;
    }
    return defaultTitle;
  }

  /// Icon paired with the error kind for consistent UI.
  static IconData iconFor({int? statusCode, String? message}) {
    if (statusCode == 401) return Icons.lock_outline_rounded;
    if (statusCode != null && statusCode >= 500) {
      return Icons.cloud_off_rounded;
    }

    final text = (message ?? '').toLowerCase();
    if (text.contains('internet') || text.contains('offline')) {
      return Icons.wifi_off_rounded;
    }
    if (text.contains('server') || text.contains('trouble reaching')) {
      return Icons.cloud_off_rounded;
    }
    return Icons.error_outline_rounded;
  }

  /// Sanitizes any thrown / stored error into safe user copy.
  static String sanitize(Object? error) {
    if (error == null) return generic;

    var raw = error.toString().trim();
    if (raw.isEmpty) return generic;

    raw = raw.replaceFirst(RegExp(r'^Exception:\s*'), '');
    raw = raw.replaceFirst(RegExp(r'^Error:\s*'), '');

    if (_looksTechnical(raw)) {
      final code = _extractStatusCode(raw);
      if (code != null) return forStatusCode(code);
      return serverUnavailable;
    }

    // Already-friendly messages from NetworkCaller / repositories.
    return raw;
  }

  static String? _cleanServerMessage(String? message) {
    if (message == null) return null;
    final trimmed = message.trim();
    if (trimmed.isEmpty) return null;
    if (_looksTechnical(trimmed)) return null;
    return trimmed;
  }

  static bool _looksTechnical(String message) {
    final lower = message.toLowerCase();
    return lower.contains('formatexception') ||
        lower.contains('unexpected character') ||
        lower.contains('unexpected server response') ||
        lower.contains('<html') ||
        lower.contains('<!doctype') ||
        RegExp(r'error code:\s*\d+', caseSensitive: false).hasMatch(message) ||
        RegExp(r'^instance of ', caseSensitive: false).hasMatch(message) ||
        message.contains('SocketException') ||
        message.contains('HttpException') ||
        message.contains('TimeoutException');
  }

  static int? _extractStatusCode(String message) {
    final match = RegExp(
      r'(?:error code|status(?: code)?)\s*[:=]?\s*(\d{3})',
      caseSensitive: false,
    ).firstMatch(message);
    if (match != null) return int.tryParse(match.group(1)!);

    final bare = RegExp(r'\b(50[0-4]|40[0-9]|42[29])\b').firstMatch(message);
    return bare != null ? int.tryParse(bare.group(1)!) : null;
  }
}
