import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Browse-business data layer: remote HTTP via [NetworkCaller].
class BrowseBusinessRepository {
  final NetworkCaller _network;

  BrowseBusinessRepository(this._network);

  Future<Map<String, dynamic>> browseBusinesses({
    required int page,
    required int limit,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'category': ?category,
    };

    final res = await _network.getRequest(
      url: AppUrl.browseBusinesses,
      queryParams: queryParams,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load businesses',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getBusinessProfile(String businessId) async {
    final res = await _network.getRequest(
      url: AppUrl.businessProfile(businessId),
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load business',
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
      url: AppUrl.otherBusinessReviews(businessId),
      queryParams: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load reviews',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> saveBusiness(String businessId) async {
    final res = await _network.postRequest(
      url: AppUrl.addBusinessToSaveList,
      body: {'businessId': businessId},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to save business',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> removeSavedBusiness(String businessId) async {
    final res = await _network.deleteRequest(
      url: AppUrl.removeSavedBusiness(businessId),
    );
    if (!res.isSuccess) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to remove',
      );
    }
    return res.body ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> postReview({
    required String businessId,
    required int rating,
    required String content,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.addReviews(businessId),
      body: {'rating': rating, 'content': content},
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to post review');
    }
    return res.body ?? <String, dynamic>{};
  }
}
