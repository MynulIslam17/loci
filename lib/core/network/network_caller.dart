import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:mime/mime.dart';
import 'network_response.dart';

class NetworkCaller {
  final Logger _logger = Logger();

  final VoidCallback onUnAuthorize;
  final String Function() accessToken;

  NetworkCaller({required this.onUnAuthorize, required this.accessToken});

  // ===========================================================
  // CENTRAL STATUS CODE → ERROR MESSAGE RESOLVER
  // Controllers never need to touch a status code directly.
  // Prefers detailed field-level "errors" from the server,
  // then the server's own "message" field, then a fallback.
  // Non-JSON bodies (e.g. Cloudflare "error code: 502") still
  // resolve via status code — they never become FormatException.
  // ===========================================================
  String _resolveErrorMessage(int statusCode, Map<String, dynamic>? decoded) {
    // Validation-style responses: {"errors": {"field": ["msg1", "msg2"]}}
    final fieldErrors = _extractFieldErrors(decoded);
    if (fieldErrors != null) return fieldErrors;

    final serverMsg = decoded?['message'] as String?;
    return AppErrorMessages.forStatusCode(statusCode, serverMessage: serverMsg);
  }

  /// Safely decode JSON. Gateways often return plain text / HTML on 5xx.
  Map<String, dynamic>? _tryDecodeBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Flattens {"errors": {"field": ["msg1", ...]}} into a readable,
  /// line-separated list of messages. Returns null if none present.
  String? _extractFieldErrors(Map<String, dynamic>? decoded) {
    final errors = decoded?['errors'];
    if (errors is! Map) return null;

    final messages = <String>[];
    for (final value in errors.values) {
      if (value is List) {
        messages.addAll(value.map((e) => e.toString()));
      } else if (value is String) {
        messages.add(value);
      }
    }

    if (messages.isEmpty) return null;
    return messages.join('\n');
  }

  // ===========================================================
  // CENTRAL UNAUTHORIZED + FORBIDDEN HANDLER
  // Call this after every non-success response.
  // ===========================================================
  void _handleAuthErrors(int statusCode, {required bool hadToken}) {
    // Only redirect when a token was sent but rejected — not for logged-out calls.
    if (statusCode == 401 && hadToken) {
      onUnAuthorize();
    }
  }

  // ===========================================================
  // GET REQUEST
  // ===========================================================
  Future<NetworkResponse> getRequest({
    required String url,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse(url);

      // Merge queryParams into the URI if provided
      if (queryParams != null && queryParams.isNotEmpty) {
        final existingParams = Map<String, String>.from(uri.queryParameters);
        final newParams = queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        existingParams.addAll(newParams);
        uri = uri.replace(queryParameters: existingParams);
      }

      final token = accessToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      _logRequest(uri.toString(), null, headers);

      final response = await get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      _logResponse(uri.toString(), response);

      final decoded = _tryDecodeBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      }

      _handleAuthErrors(response.statusCode, hadToken: token.isNotEmpty);

      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: _resolveErrorMessage(response.statusCode, decoded),
      );
    } catch (e) {
      _logger.e('GET request failed: $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: _networkExceptionMessage(e),
      );
    }
  }

  // ===========================================================
  // POST REQUEST
  // ===========================================================
  Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
    String? overrideToken,
  }) async {
    try {
      final uri = Uri.parse(url);
      final token = overrideToken ?? accessToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      _logRequest(url, body, headers);
      final response = await post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      _logResponse(url, response);

      final decoded = _tryDecodeBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      }

      if (!isFromLogin) {
        _handleAuthErrors(response.statusCode, hadToken: token.isNotEmpty);
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: _resolveErrorMessage(response.statusCode, decoded),
        body: decoded,
      );
    } catch (e) {
      _logger.e('POST request failed: $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: _networkExceptionMessage(e),
      );
    }
  }

  // ===========================================================
  // PATCH REQUEST
  // ===========================================================
  Future<NetworkResponse> patchRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      final token = accessToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      _logRequest(url, body, headers);
      final response = await patch(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      _logResponse(url, response);

      final decoded = _tryDecodeBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      }

      if (!isFromLogin) {
        _handleAuthErrors(response.statusCode, hadToken: token.isNotEmpty);
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: _resolveErrorMessage(response.statusCode, decoded),
      );
    } catch (e) {
      _logger.e('PATCH request failed: $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: _networkExceptionMessage(e),
      );
    }
  }

  // ===========================================================
  // PUT REQUEST
  // ===========================================================
  Future<NetworkResponse> putRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      final token = accessToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      _logRequest(url, body, headers);
      final response = await put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      _logResponse(url, response);

      final decoded = _tryDecodeBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      }

      if (!isFromLogin) {
        _handleAuthErrors(response.statusCode, hadToken: token.isNotEmpty);
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: _resolveErrorMessage(response.statusCode, decoded),
      );
    } catch (e) {
      _logger.e('PUT request failed: $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: _networkExceptionMessage(e),
      );
    }
  }

  // ===========================================================
  // DELETE REQUEST
  // ===========================================================
  Future<NetworkResponse> deleteRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      final token = accessToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      _logRequest(url, body, headers);
      final response = await delete(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      _logResponse(url, response);

      final decoded = _tryDecodeBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      }

      if (!isFromLogin) {
        _handleAuthErrors(response.statusCode, hadToken: token.isNotEmpty);
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: _resolveErrorMessage(response.statusCode, decoded),
        body: decoded,
      );
    } catch (e) {
      _logger.e('DELETE request failed: $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: _networkExceptionMessage(e),
      );
    }
  }

  // ===========================================================
  // MULTIPART REQUEST (POST / PATCH / PUT)
  // ===========================================================
  Future<NetworkResponse> multipartRequest({
    required String url,
    String method = 'POST',
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, List<File>>? multiFiles, // for multiple files with the same key
    bool isFromLogin = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      final token = accessToken();
      final request = http.MultipartRequest(method.toUpperCase(), uri);

      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (fields != null) request.fields.addAll(fields);

      if (files != null) {
        for (final entry in files.entries) {
          final file = entry.value;
          final fileName = file.path.split('/').last;
          final mimeType = lookupMimeType(file.path);

          request.files.add(
            http.MultipartFile(
              entry.key,
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: fileName,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ),
          );
        }
      }

      // ADD THIS BLOCK (multiple files support ( optional)) ===========================================
      if (multiFiles != null) {
        for (final entry in multiFiles.entries) {
          final key = entry.key;
          final fileList = entry.value;

          for (final file in fileList) {
            final fileName = file.path.split('/').last;
            final mimeType = lookupMimeType(file.path);

            request.files.add(
              http.MultipartFile(
                key,
                file.readAsBytes().asStream(),
                file.lengthSync(),
                filename: fileName,
                contentType: mimeType != null
                    ? MediaType.parse(mimeType)
                    : null,
              ),
            );
          }
        }
      }

      _logMultipartRequest(url, fields, files, multiFiles, request.headers);

      final streamed = await request.send().timeout(
        const Duration(seconds: 120),
      );

      final responseBody = await streamed.stream.bytesToString();
      final decoded = _tryDecodeBody(responseBody);

      // Wrap for logging
      final logResponse = Response(
        responseBody,
        streamed.statusCode,
        reasonPhrase: streamed.reasonPhrase ?? '',
      );
      _logResponse(url, logResponse);

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: streamed.statusCode,
          body: decoded,
        );
      }

      if (!isFromLogin) {
        _handleAuthErrors(streamed.statusCode, hadToken: token.isNotEmpty);
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: streamed.statusCode,
        errorMessage: _resolveErrorMessage(streamed.statusCode, decoded),
        body: decoded,
      );
    } catch (e) {
      _logger.e('MULTIPART request failed: $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: _networkExceptionMessage(e),
      );
    }
  }

  // ===========================================================
  // EXCEPTION → USER-FRIENDLY MESSAGE
  // Converts dart:io and other common exceptions to readable strings.
  // ===========================================================
  String _networkExceptionMessage(Object e) {
    if (e is TimeoutException) return AppErrorMessages.timeout;
    if (e is SocketException) return AppErrorMessages.noInternet;
    if (e is HttpException) return AppErrorMessages.network;
    // FormatException used to surface as "Unexpected server response" —
    // treat it as a transient server/gateway failure instead.
    if (e is FormatException) return AppErrorMessages.serverUnavailable;
    return AppErrorMessages.sanitize(e);
  }

  // ===========================================================
  // LOGGING
  // ===========================================================
  void _logRequest(String url, dynamic body, Map<String, String>? headers) {
    _logger.i('''
================== REQUEST ========================
URL     : $url
HEADERS : $headers
BODY    : $body
====================================================''');
  }

  void _logMultipartRequest(
    String url,
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, List<File>>? multiFiles,
    Map<String, String>? headers,
  ) {
    _logger.i('''
================== MULTIPART REQUEST ==============
URL     : $url
HEADERS : $headers
FIELDS  : $fields
====================================================''');

    // SINGLE FILES (logo etc.)
    if (files != null && files.isNotEmpty) {
      _logger.i("SINGLE FILES:");
      files.forEach((key, file) {
        _logger.i(" - $key => ${file.path.split('/').last}");
      });
    }

    // MULTI FILES (attachments etc.)
    if (multiFiles != null && multiFiles.isNotEmpty) {
      _logger.i("MULTI FILES:");
      multiFiles.forEach((key, fileList) {
        _logger.i(" - $key =>");
        for (final file in fileList) {
          _logger.i("    • ${file.path.split('/').last}");
        }
      });
    }

    _logger.i("====================================================");
  }

  void _logResponse(String url, Response response) {
    _logger.i('''
================== RESPONSE =======================
URL         : $url
STATUS CODE : ${response.statusCode}
BODY        : ${response.body}
====================================================''');
  }
}
