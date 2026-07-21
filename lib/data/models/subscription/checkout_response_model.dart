class CheckoutResponseModel {
  final bool free;
  final String planId;
  final String? customerId;
  final String? ephemeralKey;
  final String? paymentIntentClientSecret;
  final String? subscriptionId;

  CheckoutResponseModel({
    required this.free,
    required this.planId,
    this.customerId,
    this.ephemeralKey,
    this.paymentIntentClientSecret,
    this.subscriptionId,
  });

  factory CheckoutResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return CheckoutResponseModel(
      free: data['free'] == true,
      planId: data['planId']?.toString() ?? '',
      customerId: data['customerId']?.toString(),
      ephemeralKey: data['ephemeralKey']?.toString(),
      paymentIntentClientSecret:
          data['paymentIntentClientSecret']?.toString(),
      subscriptionId: data['subscriptionId']?.toString(),
    );
  }

  bool get requiresPaymentSheet =>
      !free &&
      customerId != null &&
      ephemeralKey != null &&
      paymentIntentClientSecret != null;
}
