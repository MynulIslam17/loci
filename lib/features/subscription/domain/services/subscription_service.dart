import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/data/repositories/subscription_repository.dart';

/// Domain orchestration for subscription. Controllers call this — never NetworkCaller.
class SubscriptionService {
  final SubscriptionRepository _repository;

  SubscriptionService(this._repository);

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
