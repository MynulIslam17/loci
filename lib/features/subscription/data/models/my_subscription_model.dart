/// Parsed `data` of `GET /subscriptions/my`.
///
/// `data` is `null` when the user has no active subscription — callers should
/// treat a null model as "no subscription / show plans". The subscription is
/// owner-level: one plan + one shared credit pool across every owned business.
class MySubscriptionModel {
  /// `active` while entitled — also during the store grace period and when
  /// cancelled-but-still-paid ([cancelAtPeriodEnd]).
  final String status;
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

  /// `apple` | `google` | `stripe` (legacy).
  final String? provider;

  /// Real end of access (paid-through date, or grace end).
  final String? entitlementEndsAt;

  /// Store billing problem — access continues while the store retries.
  final bool inGracePeriod;

  /// When the current monthly credit cycle ends (unused credits expire).
  final String? creditsExpireAt;

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
    this.provider,
    this.entitlementEndsAt,
    this.inGracePeriod = false,
    this.creditsExpireAt,
  });

  bool get isActive => status == 'active';

  /// Store subscriptions can only be cancelled in the App Store / Google Play.
  bool get isStoreManaged => provider == 'apple' || provider == 'google';

  /// Spotlight balance (falls back to the legacy flat field).
  int get remainingCredits => credits?.remaining ?? heroSpotlightCredits;

  /// The date access actually ends: entitlement end, else the period end.
  String? get accessEndsAt => entitlementEndsAt ?? currentPeriodEnd;

  bool get isPastDue => status == 'past_due';

  /// `amount` is in cents (Stripe convention), so convert to the charged
  /// value — e.g. 7500 → "$75", matching what Stripe bills. Empty when zero.
  String get formattedAmount {
    if (amount <= 0) return '';
    final String symbol = _currencySymbol(currency);
    final double value = amount / 100;
    final String formatted = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$symbol$formatted';
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
      heroSpotlightCredits: _toInt(json['heroSpotlightCredits']),
      currentPeriodStart: json['currentPeriodStart']?.toString(),
      currentPeriodEnd: json['currentPeriodEnd']?.toString(),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] == true,
      stripeSubscriptionId: json['stripeSubscriptionId']?.toString(),
      stripePriceId: json['stripePriceId']?.toString(),
      planId: json['planId']?.toString(),
      planName: json['planName']?.toString(),
      pendingPlanId: json['pendingPlanId']?.toString(),
      pendingPlanName: json['pendingPlanName']?.toString(),
      billingType: json['billingType']?.toString(),
      amount: _toInt(json['amount']),
      currency: json['currency']?.toString(),
      credits: credits is Map<String, dynamic>
          ? SubscriptionCredits.fromJson(credits)
          : null,
      provider: json['provider']?.toString(),
      entitlementEndsAt: json['entitlementEndsAt']?.toString(),
      inGracePeriod: json['inGracePeriod'] == true,
      creditsExpireAt: json['creditsExpireAt']?.toString(),
    );
  }
}

int _toInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
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
      total: _toInt(json['total']),
      used: _toInt(json['used']),
      remaining: _toInt(json['remaining']),
    );
  }
}
