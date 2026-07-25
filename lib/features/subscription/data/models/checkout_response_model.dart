/// Parsed `data` of `POST /subscriptions/checkout`.
///
/// The endpoint returns three shapes (see PAYMENTS.md §3):
///  A) Free plan   → `{ planId, free: true }`            → activates instantly, no PaymentSheet.
///  B) Monthly     → PaymentSheet params + `subscriptionId`.
///  C) One-time     → PaymentSheet params, no `subscriptionId`.
class CheckoutModel {
  final String planId;
  final bool isFree;
  final String? publishableKey;
  final String? customerId;
  final String? ephemeralKey;
  final String? paymentIntentClientSecret;
  final String? subscriptionId; // present for monthly plans only

  CheckoutModel({
    required this.planId,
    required this.isFree,
    this.publishableKey,
    this.customerId,
    this.ephemeralKey,
    this.paymentIntentClientSecret,
    this.subscriptionId,
  });

  /// True when we have everything needed to open Stripe's PaymentSheet.
  bool get canPresentSheet =>
      !isFree &&
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
    );
  }
}
