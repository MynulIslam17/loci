import 'package:loci/core/enums/billing_type_enum.dart';
import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/features/subscription/data/models/checkout_response_model.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/data/models/plan_response_model.dart';
import 'package:loci/features/subscription/data/models/subscription_config_model.dart';
import 'package:loci/features/subscription/data/repositories/subscription_repository.dart';

/// Domain orchestration for subscription. Controllers call this — never NetworkCaller.
class SubscriptionService {
  final SubscriptionRepository _repository;

  SubscriptionService(this._repository);

  Future<SubscriptionConfigModel> getConfig() async {
    final Map<String, dynamic> body = await _repository.getConfig();
    return SubscriptionConfigModel.fromJson(body);
  }

  Future<List<PlanModel>> getPlans(BillingType billingType) async {
    final Map<String, dynamic> body = await _repository.getPlans(billingType);
    return PlanResponseModel.fromJson(body).data;
  }

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

  Future<CheckoutModel> checkout({
    required String planId,
    required String businessId,
  }) async {
    final Map<String, dynamic> body = await _repository.checkout(
      planId: planId,
      businessId: businessId,
    );
    final dynamic data = body['data'];
    return CheckoutModel.fromJson(data is Map<String, dynamic> ? data : body);
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
