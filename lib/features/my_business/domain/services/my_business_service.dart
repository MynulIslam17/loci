import 'dart:io';

import 'package:loci/features/my_business/data/models/business_claim_request_model.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
import 'package:loci/features/my_business/data/models/business_review_model.dart';
import 'package:loci/features/my_business/data/models/create_business_request_model.dart';
import 'package:loci/features/my_business/data/models/create_business_response_model.dart';
import 'package:loci/features/my_business/data/models/find_business_response.dart';
import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/shared/models/paginated_response.dart';
import 'package:loci/features/my_business/data/repositories/my_business_repository.dart';

/// Domain orchestration for my business. Controllers call this — never NetworkCaller.
class MyBusinessService {
  final MyBusinessRepository _repository;

  MyBusinessService(this._repository);

  Future<List<BusinessModel>> getMyBusinesses({String? category}) async {
    final body = await _repository.getMyBusinesses(category: category);
    return MyBusinessResponseModel.fromJson(body).data;
  }

  Future<BusinessProfileModel> getBusinessProfile(String businessId) async {
    final body = await _repository.getBusinessProfile(businessId);
    return BusinessProfileModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> updateBusinessText({
    required String businessId,
    required Map<String, dynamic> body,
  }) async {
    final res = await _repository.updateBusinessProfile(
      businessId: businessId,
      body: body,
    );
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadBusinessImages({
    required String businessId,
    File? logo,
    List<File>? photos,
  }) async {
    final res = await _repository.uploadBusinessImages(
      businessId: businessId,
      logo: logo,
      photos: photos,
    );
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> removeBusinessPhoto({
    required String businessId,
    required String photoUrl,
  }) async {
    final res = await _repository.updateBusinessProfile(
      businessId: businessId,
      body: {
        'removePhotos': [photoUrl],
      },
    );
    return res['data'] as Map<String, dynamic>;
  }

  Future<({CreatedBusinessModel business, String message})> createBusiness(
    CreateBusinessRequestModel request, {
    List<File> attachments = const [],
  }) async {
    final body = await _repository.createBusiness(
      request: request,
      attachments: attachments,
    );
    final result = CreateBusinessResponseModel.fromJson(body);
    final data = result.data;
    if (data == null || data.id.isEmpty) {
      throw Exception('Business created but no id returned');
    }
    return (
      business: data,
      message: result.message.isNotEmpty ? result.message : 'Business created',
    );
  }

  Future<String> claimBusiness(BusinessClaimRequestModel request) async {
    final body = await _repository.claimBusiness(request);
    return body['message']?.toString() ?? 'Claim submitted';
  }

  Future<ReviewResponse> getBusinessReviews({
    required String businessId,
    required int page,
    required int limit,
  }) async {
    final body = await _repository.getBusinessReviews(
      businessId: businessId,
      page: page,
      limit: limit,
    );
    return ReviewResponse.fromJson(body);
  }

  Future<PaginatedResponse<Business>> findGoogleBusinesses({
    required int page,
    required int limit,
    String? search,
  }) async {
    final body = await _repository.findGoogleBusinesses(
      page: page,
      limit: limit,
      search: search,
    );
    return PaginatedResponse<Business>.fromJson(body, Business.fromJson);
  }

  Future<String> submitAd({
    required String title,
    required DateTime endDate,
    required File image,
    String? businessName,
    String? location,
    DateTime? startDate,
  }) async {
    final fields = <String, String>{
      'title': title,
      'endDate': endDate.toUtc().toIso8601String(),
    };
    if (businessName != null && businessName.isNotEmpty) {
      fields['businessName'] = businessName;
    }
    if (location != null && location.isNotEmpty) {
      fields['location'] = location;
    }
    if (startDate != null) {
      fields['startDate'] = startDate.toUtc().toIso8601String();
    }

    final body = await _repository.submitAd(fields: fields, image: image);
    return body['message'] as String? ?? 'Ad submitted for review';
  }

  Future<String> createActivity({
    required String url,
    required Map<String, String> body,
    Map<String, File>? files,
  }) async {
    final res = await _repository.createActivity(
      url: url,
      body: body,
      files: files,
    );
    return res['message']?.toString() ?? 'Created successfully';
  }
}
