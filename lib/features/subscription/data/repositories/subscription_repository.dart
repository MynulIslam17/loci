import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/data/models/verify_result.dart';

/// Subscription data layer: remote HTTP via [NetworkCaller].
class SubscriptionRepository {
  final NetworkCaller _network;

  SubscriptionRepository(this._network);

  /// `GET /subscriptions/account-token` — UUID attached to every purchase
  /// (StoreKit `appAccountToken` / Play `obfuscatedAccountId`).
  Future<String> getAccountToken() async {
    final NetworkResponse res = await _network.getRequest(
      url: AppUrl.subscriptionAccountToken,
    );
    final dynamic data = res.body?['data'];
    final dynamic token = data is Map ? data['appAccountToken'] : null;
    if (!res.isSuccess || token is! String || token.isEmpty) {
      throw Exception(res.errorMessage ?? 'Could not prepare the purchase.');
    }
    return token;
  }

  /// `POST /subscriptions/verify`. Never throws — every outcome is mapped to a
  /// [VerifyResult] by HTTP status + `code` (spec §4.3).
  Future<VerifyResult> verify(Map<String, dynamic> body) async {
    final NetworkResponse res = await _network.postRequest(
      url: AppUrl.verifySubscription,
      body: body,
    );
    final VerifyResultKind kind = VerifyResult.classify(
      // Offline / timeout come back as status 0 / -1 → retryable.
      res.isSuccess ? 200 : res.statusCode,
      res.errorCode ?? res.body?['code']?.toString(),
    );
    final Map<String, dynamic>? envelope = res.body;
    final dynamic data = envelope == null ? null : envelope['data'];
    final String? serverMessage = envelope == null
        ? null
        : envelope['message']?.toString();
    return VerifyResult(
      kind,
      message: res.isSuccess ? serverMessage : (serverMessage ?? res.errorMessage),
      subscription:
          kind == VerifyResultKind.success && data is Map<String, dynamic>
          ? MySubscriptionModel.fromJson(data)
          : null,
    );
  }

  /// `GET /subscriptions/my?businessId=` — owner-level subscription; any owned
  /// business works. Throws on transport/server errors so callers can keep
  /// the last known status ("network error ≠ free plan").
  Future<Map<String, dynamic>?> getMySubscription(String businessId) async {
    final NetworkResponse res = await _network.getRequest(
      url: AppUrl.mySubscription,
      queryParams: <String, dynamic>{'businessId': businessId},
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to load subscription');
    }
    return res.body;
  }

  /// Legacy Stripe cancellation only. Store plans return
  /// `400 STORE_CANCEL_REQUIRED` — open the store's management page instead.
  Future<Map<String, dynamic>?> cancelSubscription(String businessId) async {
    final NetworkResponse res = await _network.deleteRequest(
      url: '${AppUrl.mySubscription}?businessId=${Uri.encodeQueryComponent(businessId)}',
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to cancel subscription');
    }
    return res.body;
  }

  Future<Map<String, dynamic>> getMyBusinesses() async {
    final NetworkResponse res = await _network.getRequest(
      url: AppUrl.myBusiness,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.errorMessage ?? 'You need a business profile before subscribing.',
      );
    }
    return res.body!;
  }
}
