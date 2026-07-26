import 'package:loci/shared/models/review_response_model.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/browse_business/data/models/browse_business_response_model.dart';
import 'package:loci/features/browse_business/data/repositories/browse_business_repository.dart';

/// Domain orchestration for browse business. Controllers call this — never NetworkCaller.
class BrowseBusinessService {
  final BrowseBusinessRepository _repository;

  BrowseBusinessService(this._repository);

  Future<BrowseBusinessResponseModel> browseBusinesses({
    required int page,
    required int limit,
    String? category,
  }) async {
    final body = await _repository.browseBusinesses(
      page: page,
      limit: limit,
      category: category,
    );
    return BrowseBusinessResponseModel.fromJson(body);
  }

  Future<BrowseBusinessModel> getBusinessProfile(String businessId) async {
    final body = await _repository.getBusinessProfile(businessId);
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Failed to load business');
    }
    return BrowseBusinessModel.fromJson(data);
  }

  Future<ReviewResponseModel> getBusinessReviews({
    required String businessId,
    required int page,
    required int limit,
  }) async {
    final body = await _repository.getBusinessReviews(
      businessId: businessId,
      page: page,
      limit: limit,
    );
    return ReviewResponseModel.fromJson(body);
  }

  Future<String> saveBusiness(String businessId) async {
    final body = await _repository.saveBusiness(businessId);
    return body['message']?.toString() ?? 'Saved successfully';
  }

  Future<String> removeSavedBusiness(String businessId) async {
    final body = await _repository.removeSavedBusiness(businessId);
    return body['message']?.toString() ?? 'Removed successfully';
  }

  Future<void> postReview({
    required String businessId,
    required int rating,
    required String content,
  }) {
    return _repository.postReview(
      businessId: businessId,
      rating: rating,
      content: content,
    );
  }
}
