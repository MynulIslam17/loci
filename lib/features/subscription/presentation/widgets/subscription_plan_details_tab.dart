import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/store_subscription_plan.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_feature_item.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_information_card.dart';

class SubscriptionPlanDetailsTab extends StatelessWidget {
  const SubscriptionPlanDetailsTab({super.key, required this.plan});

  final StoreSubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Everything in ${plan.name}',
            style: AppTextStyle.textLg(
              color: colors.onSurface,
              weight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              children: plan.features
                  .map((String item) => SubscriptionFeatureItem(label: item))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          SubscriptionInformationCard(
            icon: Icons.refresh_rounded,
            title: 'Payments & Renewals',
            body: _renewalText(plan),
          ),
          const SizedBox(height: 12),
          const SubscriptionInformationCard(
            icon: Icons.verified_user_outlined,
            title: 'Business Owner Access',
            body:
                'Your subscription follows your Loci account, so the business tools are available across the businesses you manage.',
          ),
        ],
      ),
    );
  }

  String _renewalText(StoreSubscriptionPlan plan) {
    if (!plan.isPaid) return 'The Free plan does not renew and has no charge.';
    final bool apple = defaultTargetPlatform == TargetPlatform.iOS;
    final String store = apple ? 'Apple App Store' : 'Google Play';
    return 'Payment will be handled by $store. The ${plan.name.toLowerCase()} plan renews every ${plan.period} unless canceled in your store account.';
  }
}
