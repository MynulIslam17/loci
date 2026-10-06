import 'package:loci/features/subscription/data/config/loci_iap_products.dart';

enum StorePlanType { free, monthly, yearly }

class StoreSubscriptionPlan {
  /// Feature copy only. Paid prices are provided by the store.
  static const List<StoreSubscriptionPlan> catalog = <StoreSubscriptionPlan>[
    StoreSubscriptionPlan(
      id: 'free',
      type: StorePlanType.free,
      name: 'Free',
      period: 'forever',
      description: 'Community access and business claiming',
      features: <String>[
        'Ask and answer questions',
        'Comment on community discussions',
        'Write reviews and explore content',
        'Claim a business profile',
      ],
    ),
    StoreSubscriptionPlan(
      id: 'monthly',
      productId: LociIapProducts.monthly,
      type: StorePlanType.monthly,
      name: 'Monthly',
      period: 'month',
      description: 'Full business features with monthly flexibility',
      badge: 'Most Popular',
      features: <String>[
        'Business Community features',
        'Create Events, Routes and Raffles',
        'Create Spotlight Ads',
        '100 Spotlight credits every month',
      ],
    ),
    StoreSubscriptionPlan(
      id: 'yearly',
      productId: LociIapProducts.yearly,
      type: StorePlanType.yearly,
      name: 'Yearly',
      period: 'year',
      description: 'The same full features at the best value',
      features: <String>[
        'All features from Monthly',
        '100 Spotlight credits every month',
        'One yearly payment',
        'Yearly billing',
      ],
    ),
  ];

  const StoreSubscriptionPlan({
    required this.id,
    this.productId,
    required this.type,
    required this.name,
    required this.period,
    required this.description,
    required this.features,
    this.badge,
  });

  final String id;
  final String? productId;
  final StorePlanType type;
  final String name;
  final String period;
  final String description;
  final List<String> features;
  final String? badge;

  bool get isPaid => type != StorePlanType.free;
}
