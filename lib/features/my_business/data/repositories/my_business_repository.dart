import 'dart:io';

import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/features/my_business/data/models/business_claim_request_model.dart';
import 'package:loci/features/my_business/data/models/create_business_request_model.dart';

/// My Business data layer: remote HTTP via [NetworkCaller].
class MyBusinessRepository {
  final NetworkCaller _network;

  MyBusinessRepository(this._network);

  Future<Map<String, dynamic>> getMyBusinesses({String? category}) async {
    final res = await _network.getRequest(
      url: AppUrl.myBusiness,
      queryParams: category != null ? {'category': category} : null,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Something went wrong');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getBusinessProfile(String businessId) async {
    final res = await _network.getRequest(
      url: AppUrl.businessProfile(businessId),
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load business profile');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> updateBusinessProfile({
    required String businessId,
    required Map<String, dynamic> body,
  }) async {
    final res = await _network.patchRequest(
      url: AppUrl.updateBusinessProfile(businessId),
      body: body,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Update failed');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> uploadBusinessImages({
    required String businessId,
    File? logo,
    List<File>? photos,
  }) async {
    final files = <String, File>{};
    final multiFiles = <String, List<File>>{};

    if (logo != null) files['logo'] = logo;
    if (photos != null && photos.isNotEmpty) multiFiles['photos'] = photos;

    final res = await _network.multipartRequest(
      url: AppUrl.updateBusinessProfile(businessId),
      method: 'PATCH',
      files: files,
      multiFiles: multiFiles,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to upload images');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> createBusiness({
    required CreateBusinessRequestModel request,
    List<File> attachments = const [],
  }) async {
    final res = await _network.multipartRequest(
      url: AppUrl.createBusiness,
      fields: request.toFields(),
      multiFiles: attachments.isEmpty
          ? null
          : request.attachmentsMultiFileMap(attachments),
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        _parseErrorMessage(res.body) ??
            res.errorMessage ??
            'Failed to create business',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> claimBusiness(
    BusinessClaimRequestModel request,
  ) async {
    final res = await _network.multipartRequest(
      url: AppUrl.claimBusiness,
      fields: request.toFields(),
      multiFiles: request.toMultiFileMap(),
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        _parseErrorMessage(res.body) ??
            res.errorMessage ??
            'Failed to submit claim',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getBusinessReviews({
    required String businessId,
    required int page,
    required int limit,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.myBusinessReviews(businessId),
      queryParams: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load reviews',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> findGoogleBusinesses({
    required int page,
    required int limit,
    String? search,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.findGoogleBusiness,
      queryParams: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Something went wrong');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> submitAd({
    required Map<String, String> fields,
    required File image,
  }) async {
    final res = await _network.multipartRequest(
      url: AppUrl.submitAd,
      method: 'POST',
      fields: fields,
      files: {'image': image},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        _parseErrorMessage(res.body) ??
            res.errorMessage ??
            'Failed to submit ad',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getMyAds({
    required int page,
    required int limit,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.myAds,
      queryParams: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        _parseErrorMessage(res.body) ??
            res.errorMessage ??
            'Failed to load ads',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> createActivity({
    required String url,
    required Map<String, String> body,
    Map<String, File>? files,
  }) async {
    final res = await _network.multipartRequest(
      url: url,
      method: 'POST',
      fields: body,
      files: files,
    );
    if (!res.isSuccess) {
      final message =
          res.body?['errors']?['details']?[0] ??
          res.body?['message'] ??
          res.errorMessage ??
          'Failed to create activity';
      throw Exception(message.toString());
    }
    return res.body ?? const {};
  }

  String? _parseErrorMessage(Map<String, dynamic>? body) {
    if (body == null) return null;

    final errors = body['errors'];
    if (errors is Map<String, dynamic>) {
      for (final entry in errors.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value != null) return value.toString();
      }
    }

    return body['message'] as String?;
  }
}
