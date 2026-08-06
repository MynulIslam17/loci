import 'dart:io';

import 'package:loci/shared/models/paginated_response.dart';
import 'package:loci/features/common/data/repositories/common_repository.dart';

/// Domain orchestration for shared HTTP helpers. Controllers call this — never NetworkCaller.
class CommonService {
  final CommonRepository _repository;

  CommonService(this._repository);

  Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
    String? overrideToken,
  }) {
    return _repository.post(url: url, body: body, overrideToken: overrideToken);
  }

  Future<Map<String, dynamic>> patch({
    required String url,
    required Map<String, dynamic> body,
  }) {
    return _repository.patch(url: url, body: body);
  }

  Future<Map<String, dynamic>> multipart({
    required String url,
    required Map<String, String> fields,
    Map<String, File>? files,
    String method = 'POST',
  }) {
    return _repository.multipart(
      url: url,
      fields: fields,
      files: files,
      method: method,
    );
  }

  Future<PaginatedResponse<T>> getPaginated<T>({
    required String url,
    required Map<String, dynamic> queryParams,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final body = await _repository.get(url: url, queryParams: queryParams);
    return PaginatedResponse<T>.fromJson(body, fromJson);
  }

  Future<Map<String, dynamic>> checkIn(Map<String, dynamic> body) async {
    return _repository.checkIn(body);
  }

  Future<Map<String, dynamic>> manualCheckIn({
    required String type,
    required Map<String, dynamic> body,
  }) async {
    return _repository.manualCheckIn(type: type, body: body);
  }
}
