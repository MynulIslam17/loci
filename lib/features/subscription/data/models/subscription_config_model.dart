class SubscriptionConfigModel {
  final String publishableKey;

  SubscriptionConfigModel({required this.publishableKey});

  factory SubscriptionConfigModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? {};
    return SubscriptionConfigModel(
      publishableKey: data['publishableKey'] ?? '',
    );
  }
}
