/// Parsed `data` of `POST /subscriptions/checkout`.
///
/// The endpoint returns five shapes (see PAYMENTS.md §3):
///  A) Free plan     → `{ planId, free: true }`                 → activates instantly, no PaymentSheet.
///  B) Monthly (new) → PaymentSheet params + `subscriptionId`.
///  C) One-time      → PaymentSheet params, no `subscriptionId`.
///  D) Upgrade       → `{ planId, switched: true, ... }` — applied immediately;
///     PaymentSheet params present only if the prorated charge needs confirmation.
///  E) Downgrade     → `{ planId, scheduled: true, pendingPlanName, effectiveDate }`
///     — nothing to confirm; the switch takes effect at `effectiveDate`.
class CheckoutModel {
  final String planId;
  final bool isFree;
  final String? publishableKey;
  final String? customerId;
  final String? ephemeralKey;
  final String? paymentIntentClientSecret;
  final String? subscriptionId; // present for monthly plans only
  final bool switched;
  final bool scheduled;
  final String? pendingPlanName;
  final String? effectiveDate;

  CheckoutModel({
    required this.planId,
    required this.isFree,
    this.publishableKey,
    this.customerId,
    this.ephemeralKey,
    this.paymentIntentClientSecret,
    this.subscriptionId,
    this.switched = false,
    this.scheduled = false,
    this.pendingPlanName,
    this.effectiveDate,
  });

  /// True when we have everything needed to open Stripe's PaymentSheet.
  bool get canPresentSheet =>
      !isFree &&
      !scheduled &&
      (customerId?.isNotEmpty ?? false) &&
      (ephemeralKey?.isNotEmpty ?? false) &&
      (paymentIntentClientSecret?.isNotEmpty ?? false);

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    // Backend field names have drifted across deploys — accept common aliases
    // so a successful checkout still opens PaymentSheet on device.
    final String? ephemeral = _firstNonEmpty(json, const [
      'ephemeralKey',
      'ephemeralKeySecret',
      'customerEphemeralKeySecret',
      'customer_ephemeral_key_secret',
    ]);
    final String? clientSecret = _firstNonEmpty(json, const [
      'paymentIntentClientSecret',
      'clientSecret',
      'payment_intent_client_secret',
      'setupIntentClientSecret',
    ]);
    final String? customer = _firstNonEmpty(json, const [
      'customerId',
      'customer_id',
      'stripeCustomerId',
    ]);

    return CheckoutModel(
      planId: (json['planId'] ?? json['plan_id'] ?? '').toString(),
      isFree: json['free'] == true,
      publishableKey: _firstNonEmpty(json, const [
        'publishableKey',
        'publishable_key',
        'stripePublishableKey',
      ]),
      customerId: customer,
      ephemeralKey: ephemeral,
      paymentIntentClientSecret: clientSecret,
      subscriptionId: json['subscriptionId']?.toString() ??
          json['subscription_id']?.toString(),
      switched: json['switched'] == true,
      scheduled: json['scheduled'] == true,
      pendingPlanName: json['pendingPlanName']?.toString(),
      effectiveDate: json['effectiveDate']?.toString(),
    );
  }

  static String? _firstNonEmpty(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
