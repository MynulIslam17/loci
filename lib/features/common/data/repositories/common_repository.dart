import 'dart:io';

import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Shared HTTP helpers used by common/reusable controllers.
class CommonRepository {
  final NetworkCaller _network;

  CommonRepository(this._network);

  Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
    String? overrideToken,
  }) async {
    final res = await _network.postRequest(
      url: url,
      body: body,
      overrideToken: overrideToken,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Submission failed');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> patch({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    final res = await _network.patchRequest(url: url, body: body);
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Submission failed');
    }
    return res.body ?? const {};
  }

  Future<Map<String, dynamic>> multipart({
    required String url,
    required Map<String, String> fields,
    Map<String, File>? files,
    String method = 'POST',
  }) async {
    final res = await _network.multipartRequest(
      url: url,
      method: method,
      fields: fields,
      files: files,
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Request failed');
    }
    return res.body ?? const {};
  }

  Future<Map<String, dynamic>> get({
    required String url,
    Map<String, dynamic>? queryParams,
  }) async {
    final res = await _network.getRequest(url: url, queryParams: queryParams);
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Something went wrong');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> checkIn(Map<String, dynamic> body) async {
    final res = await _network.postRequest(url: AppUrl.checkIn, body: body);
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.body?['message'] ?? 'Check-in failed');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> manualCheckIn({
    required String type,
    required Map<String, dynamic> body,
  }) async {
    final url = type == 'event'
        ? AppUrl.eventManualCheckIn
        : AppUrl.routeManualCheckIn;
    final res = await _network.postRequest(url: url, body: body);
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.body?['message'] ?? 'Check-in failed');
    }
    return res.body!;
  }
}
