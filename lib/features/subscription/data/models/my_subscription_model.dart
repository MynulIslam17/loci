/// Parsed `data` of `GET /subscriptions/my`.
///
/// `data` is `null` when the user has no active subscription — callers should
/// treat a null model as "no subscription / show plans".
class MySubscriptionModel {
  final String status; // active | past_due | incomplete | cancelled ...
  final int heroSpotlightCredits;
  final String? currentPeriodStart;
  final String? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final String? stripeSubscriptionId;
  final String? stripePriceId;
  final String? planId;
  final String? planName;

  /// Set while a downgrade is scheduled to take effect at [currentPeriodEnd]
  /// instead of right away — null means no switch is pending.
  final String? pendingPlanId;
  final String? pendingPlanName;
  final String? billingType; // monthly | yearly ...
  final int amount; // minor units (cents)
  final String? currency; // usd ...
  final SubscriptionCredits? credits;

  MySubscriptionModel({
    required this.status,
    required this.heroSpotlightCredits,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    this.stripeSubscriptionId,
    this.stripePriceId,
    this.planId,
    this.planName,
    this.pendingPlanId,
    this.pendingPlanName,
    this.billingType,
    this.amount = 0,
    this.currency,
    this.credits,
  });

  bool get isActive => status == 'active';

  bool get isPastDue => status == 'past_due';

  /// Price shown exactly as the backend sends it (no unit conversion),
  /// e.g. amount 7500 → "$7500". Empty when there's no amount.
  String get formattedAmount {
    if (amount <= 0) return '';
    final String symbol = _currencySymbol(currency);
    return '$symbol$amount';
  }

  static String _currencySymbol(String? currency) {
    switch (currency?.toLowerCase()) {
      case 'usd':
        return '\$';
      case 'eur':
        return '€';
      case 'gbp':
        return '£';
      default:
        return currency != null && currency.isNotEmpty
            ? '${currency.toUpperCase()} '
            : '\$';
    }
  }

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    final dynamic credits = json['credits'];
    return MySubscriptionModel(
      status: json['status'] ?? '',
      heroSpotlightCredits: json['heroSpotlightCredits'] ?? 0,
      currentPeriodStart: json['currentPeriodStart']?.toString(),
      currentPeriodEnd: json['currentPeriodEnd']?.toString(),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] == true,
      stripeSubscriptionId: json['stripeSubscriptionId'],
      stripePriceId: json['stripePriceId'],
      planId: json['planId']?.toString(),
      planName: json['planName']?.toString(),
      pendingPlanId: json['pendingPlanId']?.toString(),
      pendingPlanName: json['pendingPlanName']?.toString(),
      billingType: json['billingType']?.toString(),
      amount: json['amount'] ?? 0,
      currency: json['currency']?.toString(),
      credits: credits is Map<String, dynamic>
          ? SubscriptionCredits.fromJson(credits)
          : null,
    );
  }
}

/// Credit usage breakdown for the active plan.
class SubscriptionCredits {
  final int total;
  final int used;
  final int remaining;

  const SubscriptionCredits({
    required this.total,
    required this.used,
    required this.remaining,
  });

  /// Fraction of credits remaining (0..1), for a progress bar.
  double get remainingFraction =>
      total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;

  factory SubscriptionCredits.fromJson(Map<String, dynamic> json) {
    return SubscriptionCredits(
      total: json['total'] ?? 0,
      used: json['used'] ?? 0,
      remaining: json['remaining'] ?? 0,
    );
  }
}
