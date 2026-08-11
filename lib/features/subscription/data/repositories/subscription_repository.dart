import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/enums/billing_type_enum.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

/// Subscription data layer: remote HTTP via [NetworkCaller].
class SubscriptionRepository {
  final NetworkCaller _network;

  SubscriptionRepository(this._network);

  Future<Map<String, dynamic>> getConfig() async {
    final NetworkResponse res = await _network.getRequest(
      url: AppUrl.subscriptionConfig,
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load payment config');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getPlans(BillingType billingType) async {
    final NetworkResponse res = await _network.getRequest(
      url: '${AppUrl.subscriptionPlans}?billingType=${billingType.toJson}',
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load plans');
    }
    return res.body!;
  }

  /// `businessId` is required — subscriptions are per-business, so the backend
  /// now rejects this call with 400 without it (owners of >1 business would
  /// otherwise get the wrong plan back).
  Future<Map<String, dynamic>?> getMySubscription(String businessId) async {
    final NetworkResponse res = await _network.getRequest(
      url: '${AppUrl.mySubscription}?businessId=$businessId',
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to load subscription');
    }
    return res.body;
  }

  Future<Map<String, dynamic>> checkout({
    required String planId,
    required String businessId,
  }) async {
    final NetworkResponse res = await _network.postRequest(
      url: AppUrl.subscriptionCheckout,
      body: {'planId': planId, 'businessId': businessId},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Checkout failed');
    }
    return res.body!;
  }

  /// Same per-business scoping as [getMySubscription] — `businessId` is required
  /// so the right business's plan is cancelled (400 without it).
  Future<Map<String, dynamic>?> cancelSubscription(String businessId) async {
    final NetworkResponse res = await _network.deleteRequest(
      url: '${AppUrl.mySubscription}?businessId=$businessId',
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
