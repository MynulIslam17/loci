import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'network_response.dart';



class NetworkCaller {
  final String _defaultErrorMessage = 'Something went wrong. Please try again.';
  final Logger _logger = Logger();

  final VoidCallback onUnAuthorize;
  final String Function() accessToken;

  NetworkCaller({
    required this.onUnAuthorize,
    required this.accessToken,
  });

  // ===========================================================
  // CENTRAL STATUS CODE → ERROR MESSAGE RESOLVER
  // Controllers never need to touch a status code directly.
  // Always tries the server's own "message" field first.
  // ===========================================================
  String _resolveErrorMessage(int statusCode, Map<String, dynamic>? decoded) {
    final serverMsg = decoded?['message'] as String?;

    switch (statusCode) {
      case 400:
        return serverMsg ?? 'Bad request. Please check your input.';
      case 401:
        return serverMsg ?? 'Session expired. Please log in again.';
      case 403:
        return serverMsg ?? 'You don\'t have permission to perform this action.';
      case 404:
        return serverMsg ?? 'The requested resource was not found.';
      case 408:
        return serverMsg ?? 'Request timed out. Please try again.';
      case 409:
        return serverMsg ?? 'Conflict. This resource already exists.';
      case 422:
        return serverMsg ?? 'Invalid data submitted. Please review your input.';
      case 429:
        return serverMsg ?? 'Too many requests. Please wait a moment and try again.';
      case 500:
        return serverMsg ?? 'Server error. Please try again later.';
      case 502:
        return serverMsg ?? 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        return serverMsg ?? 'Service unavailable. Please try again later.';
      case 504:
        return serverMsg ?? 'Gateway timeout. Please check your connection and try again.';
      default:
        return serverMsg ?? _defaultErrorMessage;
    }
  }

  // ===========================================================
  // CENTRAL UNAUTHORIZED + FORBIDDEN HANDLER
  // Call this after every non-success response.
  // ===========================================================
  void _handleAuthErrors(int statusCode) {
    if (statusCode == 401) {
      onUnAuthorize();
    }
    // 403 does not call onUnAuthorize because the token is still valid —
    // the user simply lacks permission. Handle UI feedback via errorMessage.
  }

  // ===========================================================
  // GET REQUEST
  // ===========================================================
  Future<NetworkResponse> getRequest({required String url}) async {
    try {
      final uri = Uri.parse(url);
      final headers = {
        'Authorization': 'Bearer ${accessToken()}',
        'Content-Type': 'application/json',
      };

      _logRequest(url, null, headers);

      final response = await get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      _logResponse(url, response);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      }

      _handleAuthErrors(response.statusCode);

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
      final response = await post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      _logResponse(url, response);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      }

      if (!isFromLogin) _handleAuthErrors(response.statusCode);

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
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${accessToken()}',
      };

      _logRequest(url, body, headers);
      final response = await patch(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      _logResponse(url, response);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      }

      if (!isFromLogin) _handleAuthErrors(response.statusCode);

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
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${accessToken()}',
      };

      _logRequest(url, body, headers);
      final response = await put(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      _logResponse(url, response);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      }

      if (!isFromLogin) _handleAuthErrors(response.statusCode);

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
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${accessToken()}',
      };

      _logRequest(url, body, headers);
      final response = await delete(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      _logResponse(url, response);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      }

      if (!isFromLogin) _handleAuthErrors(response.statusCode);

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
    bool isFromLogin = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest(method.toUpperCase(), uri);

      request.headers['Authorization'] = 'Bearer ${accessToken()}';

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

      _logMultipartRequest(url, fields, files, request.headers);

      final streamed = await request.send()
          .timeout(const Duration(seconds: 120));

      final responseBody = await streamed.stream.bytesToString();
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>?;

      // Wrap for logging
      final logResponse = Response(responseBody, streamed.statusCode,
          reasonPhrase: streamed.reasonPhrase ?? '');
      _logResponse(url, logResponse);

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: streamed.statusCode,
          body: decoded,
        );
      }

      if (!isFromLogin) _handleAuthErrors(streamed.statusCode);

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

    if (e is TimeoutException) {
      return 'Request timed out. Please check your connection.';
    }
    if (e is SocketException) {
      return 'No internet connection. Please check your network.';
    }
    if (e is HttpException) {
      return 'Network error. Please try again.';
    }
    if (e is FormatException) {
      return 'Unexpected server response. Please try again.';
    }
    return 'Something went wrong. Please try again.';
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
      Map<String, String>? headers,
      ) {
    _logger.i('''
================== MULTIPART REQUEST ==============
URL     : $url
HEADERS : $headers
FIELDS  : $fields
FILES   : ${files?.keys.toList()}
====================================================''');
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