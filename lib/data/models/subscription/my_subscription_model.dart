class MySubscriptionModel {
  final String id;
  final String status;
  final String planId;
  final int heroSpotlightCredits;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;

  MySubscriptionModel({
    required this.id,
    required this.status,
    required this.planId,
    required this.heroSpotlightCredits,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
  });

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MySubscriptionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      planId: json['planId']?.toString() ?? '',
      heroSpotlightCredits: json['heroSpotlightCredits'] ?? 0,
      currentPeriodEnd: json['currentPeriodEnd'] != null
          ? DateTime.tryParse(json['currentPeriodEnd'].toString())
          : null,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] == true,
    );
  }

  bool get isActive => status == 'active';
  bool get isPastDue => status == 'past_due';
  bool get isIncomplete => status == 'incomplete';
}
