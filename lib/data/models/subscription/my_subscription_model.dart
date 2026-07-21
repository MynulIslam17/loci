/// Parsed `data` of `GET /subscriptions/my`.
///
/// `data` is `null` when the user has no active subscription — callers should
/// treat a null model as "no subscription / show plans".
class MySubscriptionModel {
  final String status; // active | past_due | incomplete | cancelled ...
  final int heroSpotlightCredits;
  final String? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final String? stripeSubscriptionId;
  final String? stripePriceId;
  final String? planId;
  final String? planName;
  final int amount;

  MySubscriptionModel({
    required this.status,
    required this.heroSpotlightCredits,
    this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    this.stripeSubscriptionId,
    this.stripePriceId,
    this.planId,
    this.planName,
    this.amount = 0,
  });

  bool get isActive => status == 'active';

  bool get isPastDue => status == 'past_due';

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MySubscriptionModel(
      status: json['status'] ?? '',
      heroSpotlightCredits: json['heroSpotlightCredits'] ?? 0,
      currentPeriodEnd: json['currentPeriodEnd']?.toString(),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] == true,
      stripeSubscriptionId: json['stripeSubscriptionId'],
      stripePriceId: json['stripePriceId'],
      planId: json['planId']?.toString(),
      planName: json['planName']?.toString(),
      amount: json['amount'] ?? 0,
    );
  }
}
