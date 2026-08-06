import 'package:loci/shared/models/review_response_model.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/browse_business/data/models/browse_business_response_model.dart';
import 'package:loci/shared/models/review_model.dart';
import 'package:loci/features/browse_business/data/repositories/browse_business_repository.dart';

/// Domain orchestration for browse business. Controllers call this — never NetworkCaller.
class BrowseBusinessService {
  final BrowseBusinessRepository _repository;

  BrowseBusinessService(this._repository);

  Future<BrowseBusinessResponseModel> browseBusinesses({
    required int page,
    required int limit,
    String? category,
    String? search,
  }) async {
    final body = await _repository.browseBusinesses(
      page: page,
      limit: limit,
      category: category,
      search: search,
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

  Future<({String message, ReviewModel review})> postReview({
    required String businessId,
    required int rating,
    required String content,
  }) async {
    final body = await _repository.postReview(
      businessId: businessId,
      rating: rating,
      content: content,
    );
    final data = body['data'];
    final message = body['message']?.toString() ?? 'Review submitted';
    if (data is Map<String, dynamic>) {
      final review = ReviewModel.fromJson({
        ...data,
        if (data['business'] == null || data['business'] == '')
          'business': businessId,
      });
      return (message: message, review: review);
    }
    throw Exception('Review posted but response was invalid');
  }
}
