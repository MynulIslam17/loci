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
    return CheckoutModel(
      planId: json['planId'] ?? '',
      isFree: json['free'] == true,
      publishableKey: json['publishableKey'],
      customerId: json['customerId'],
      ephemeralKey: json['ephemeralKey'],
      paymentIntentClientSecret: json['paymentIntentClientSecret'],
      subscriptionId: json['subscriptionId'],
      switched: json['switched'] == true,
      scheduled: json['scheduled'] == true,
      pendingPlanName: json['pendingPlanName']?.toString(),
      effectiveDate: json['effectiveDate']?.toString(),
    );
  }
}
