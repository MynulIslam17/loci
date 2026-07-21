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

  MySubscriptionModel({
    required this.status,
    required this.heroSpotlightCredits,
    this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    this.stripeSubscriptionId,
    this.stripePriceId,
  });

  bool get isActive => status == 'active';

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MySubscriptionModel(
      status: json['status'] ?? '',
      heroSpotlightCredits: json['heroSpotlightCredits'] ?? 0,
      currentPeriodEnd: json['currentPeriodEnd']?.toString(),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] == true,
      stripeSubscriptionId: json['stripeSubscriptionId'],
      stripePriceId: json['stripePriceId'],
    );
  }
}
