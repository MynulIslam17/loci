import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/image_upload_preparer.dart';
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
    // Field-level validation messages (e.g. "Please provide a valid email
    // address") are far more useful than the generic wrapper message
    // ("Validation failed"), so prefer them when present. Auth failures (wrong
    // email/password) intentionally don't carry an `errors` map, so this never
    // turns those into an enumeration ("no such email" vs "wrong password")
    // leak — it only ever surfaces genuine per-field input validation problems.
    // Shape: {"errors": {"field": ["msg1", "msg2"]}}
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
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

  /// GET whose successful body is plain text (e.g. CSV export).
  Future<String> getTextBody({required String url}) async {
    try {
      final uri = Uri.parse(url);
      final token = accessToken();
      final headers = {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      _logRequest(uri.toString(), null, headers);

      final response = await get(uri, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      _logResponse(uri.toString(), response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }

      final decoded = _tryDecodeBody(response.body);
      _handleAuthErrors(response.statusCode, hadToken: token.isNotEmpty);
      throw Exception(_resolveErrorMessage(response.statusCode, decoded));
    } catch (e) {
      _logger.e('GET text request failed: $e');
      if (e is Exception) rethrow;
      throw Exception(_networkExceptionMessage(e));
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
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
          request.files.add(await _buildMultipartFile(entry.key, entry.value));
        }
      }

      // ADD THIS BLOCK (multiple files support ( optional)) ===========================================
      if (multiFiles != null) {
        for (final entry in multiFiles.entries) {
          final key = entry.key;
          final fileList = entry.value;

          for (final file in fileList) {
            request.files.add(await _buildMultipartFile(key, file));
          }
        }
      }

      _logMultipartRequest(url, fields, files, multiFiles, request.headers);

      final streamed = await request.send().timeout(
        const Duration(seconds: 120),
      );

      final responseBody = await streamed.stream.bytesToString();
      final decoded = _tryDecodeBody(responseBody);

      // Wrap for logging. Force UTF-8: the default Response(String) constructor
      // re-encodes the body as Latin-1, which throws "Contains invalid
      // characters" on non-Latin scripts (e.g. Bengali) — turning a successful
      // response into a false failure.
      final logResponse = Response(
        responseBody,
        streamed.statusCode,
        headers: const {'content-type': 'application/json; charset=utf-8'},
        reasonPhrase: streamed.reasonPhrase ?? '',
      );
      _logResponse(url, logResponse);

      if (streamed.statusCode == 200 ||
          streamed.statusCode == 201 ||
          streamed.statusCode == 204) {
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

  /// Builds a multipart part from bytes so iOS TestFlight can still upload
  /// after the original picker path is no longer readable.
  /// Images are sent as JPEG/PNG; PDFs and docs keep their real type.
  Future<http.MultipartFile> _buildMultipartFile(String field, File file) async {
    var bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('Selected file could not be read');
    }

    if (ImageUploadPreparer.looksLikeImage(bytes, file.path)) {
      final isJpeg = _isJpeg(bytes);
      final isPng = _isPng(bytes);
      if (!isJpeg && !isPng) {
        final prepared = await ImageUploadPreparer.fromBytes(
          bytes,
          sourcePath: file.path,
        );
        bytes = await prepared.readAsBytes();
      }
      final sendPng = _isPng(bytes) && !_isJpeg(bytes);
      return http.MultipartFile.fromBytes(
        field,
        bytes,
        filename: sendPng ? 'image.png' : 'image.jpg',
        contentType: sendPng
            ? MediaType('image', 'png')
            : MediaType('image', 'jpeg'),
      );
    }

    final originalName = file.path.split(RegExp(r'[/\\]')).last;
    final fileName = originalName.contains('.') ? originalName : 'file.bin';
    return http.MultipartFile.fromBytes(
      field,
      bytes,
      filename: fileName,
      contentType: _contentTypeFor(fileName, bytes),
    );
  }

  bool _isJpeg(List<int> bytes) =>
      bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8;

  bool _isPng(List<int> bytes) =>
      bytes.length > 3 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47;

  MediaType _contentTypeFor(String fileName, List<int> bytes) {
    final lower = fileName.toLowerCase();
    final isPdf =
        lower.endsWith('.pdf') ||
        (bytes.length > 3 &&
            bytes[0] == 0x25 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x44 &&
            bytes[3] == 0x46);
    if (isPdf) return MediaType('application', 'pdf');
    if (lower.endsWith('.doc')) return MediaType('application', 'msword');
    if (lower.endsWith('.docx')) {
      return MediaType(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    }
    return MediaType('application', 'octet-stream');
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
