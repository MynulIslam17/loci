class IapConfig {
  const IapConfig({
    required this.productIds,
    this.consumableIds = const <String>{},
  });

  final Set<String> productIds;
  final Set<String> consumableIds;

  bool isConsumable(String productId) => consumableIds.contains(productId);
}
