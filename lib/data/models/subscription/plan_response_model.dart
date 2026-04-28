import '../../../core/enums/billing_type_enum.dart';

class PlanResponseModel {
  final bool success;
  final String message;
  final List<PlanModel> data;

  PlanResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PlanResponseModel.fromJson(Map<String, dynamic> json) {
    return PlanResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => PlanModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}



class PlanModel {
  final String id;
  final String realProductId;
  final String name;
  final BillingType billingType;
  final int amount;
  final String currency;
  final int heroSpotlightCredits;
  final List<String> features;

  PlanModel({
    required this.id,
    required this.realProductId,
    required this.name,
    required this.billingType,
    required this.amount,
    required this.currency,
    required this.heroSpotlightCredits,
    required this.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? '',
      realProductId: json['realProductId'] ?? '',
      name: json['name'] ?? '',
      billingType: BillingType.fromString(json['billingType']),
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? '',
      heroSpotlightCredits: json['heroSpotlightCredits'] ?? 0,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}