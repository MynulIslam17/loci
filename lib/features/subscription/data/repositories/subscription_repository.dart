import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/enums/billing_type_enum.dart';
import 'package:loci/core/network/network_caller.dart';

/// Subscription data layer: remote HTTP via [NetworkCaller].
class SubscriptionRepository {
  final NetworkCaller _network;

  SubscriptionRepository(this._network);

  Future<Map<String, dynamic>> getConfig() async {
    final res = await _network.getRequest(url: AppUrl.subscriptionConfig);
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load payment config');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getPlans(BillingType billingType) async {
    final res = await _network.getRequest(
      url: '${AppUrl.subscriptionPlans}?billingType=${billingType.toJson}',
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load plans');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>?> getMySubscription() async {
    final res = await _network.getRequest(url: AppUrl.mySubscription);
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to load subscription');
    }
    return res.body;
  }

  Future<Map<String, dynamic>> checkout({
    required String planId,
    required String businessId,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.subscriptionCheckout,
      body: {'planId': planId, 'businessId': businessId},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Checkout failed');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>?> cancelSubscription() async {
    final res = await _network.deleteRequest(url: AppUrl.mySubscription);
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to cancel subscription');
    }
    return res.body;
  }

  Future<Map<String, dynamic>> getMyBusinesses() async {
    final res = await _network.getRequest(url: AppUrl.myBusiness);
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.errorMessage ?? 'You need a business profile before subscribing.',
      );
    }
    return res.body!;
  }
}
