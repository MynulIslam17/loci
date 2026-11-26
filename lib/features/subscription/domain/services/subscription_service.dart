import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/data/models/verify_result.dart';
import 'package:loci/features/subscription/data/repositories/subscription_repository.dart';

/// Domain orchestration for subscription. Controllers call this — never NetworkCaller.
class SubscriptionService {
  final SubscriptionRepository _repository;

  SubscriptionService(this._repository);

  /// Account token is stable per user — cached per Loci user id.
  final Map<String, String> _accountTokens = <String, String>{};

  Future<String> getAccountToken(String userId) async {
    final String? cached = _accountTokens[userId];
    if (cached != null) return cached;
    final String token = await _repository.getAccountToken();
    if (userId.isNotEmpty) _accountTokens[userId] = token;
    return token;
  }

  void clearCachedAccountTokens() => _accountTokens.clear();

  Future<VerifyResult> verifyPurchase(Map<String, dynamic> body) =>
      _repository.verify(body);

  /// `null` = 200 with `data: null` → free plan. Throws on network errors.
  Future<MySubscriptionModel?> getMySubscription(String businessId) async {
    final Map<String, dynamic>? body = await _repository.getMySubscription(
      businessId,
    );
    if (body == null) return null;
    final dynamic data = body['data'];
    if (data is Map<String, dynamic>) {
      return MySubscriptionModel.fromJson(data);
    }
    return null;
  }

  Future<MySubscriptionModel?> cancelSubscription(String businessId) async {
    final Map<String, dynamic>? body = await _repository.cancelSubscription(
      businessId,
    );
    final dynamic data = body?['data'];
    if (data is Map<String, dynamic>) {
      return MySubscriptionModel.fromJson(data);
    }
    return null;
  }

  Future<List<BusinessModel>> getMyBusinesses() async {
    final Map<String, dynamic> body = await _repository.getMyBusinesses();
    return MyBusinessResponseModel.fromJson(body).data;
  }
}
