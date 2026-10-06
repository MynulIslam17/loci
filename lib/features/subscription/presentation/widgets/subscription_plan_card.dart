import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/store_subscription_plan.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_feature_item.dart';

class SubscriptionPlanCard extends StatelessWidget {
  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    this.storePrice,
  });

  final StoreSubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final String? storePrice;

  Color _accent(ColorScheme colors) {
    return switch (plan.type) {
      StorePlanType.free => const Color(0xFF6B7280),
      StorePlanType.monthly => const Color(0xFF246BFD),
      StorePlanType.yearly => const Color(0xFF16A36A),
    };
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;
    final Color accent = _accent(colors);

    return Semantics(
      selected: isSelected,
      button: true,
      label:
          '${plan.name} plan, ${plan.isPaid ? (storePrice ?? 'Price unavailable') : 'Free'}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: plan.type == StorePlanType.yearly
              ? const Color(0xFFF7FCF7)
              : plan.type == StorePlanType.monthly
              ? const Color(0xFFF7FAFF)
              : colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accent : accent.withValues(alpha: .19),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isSelected
                  ? accent.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.035),
              blurRadius: isSelected ? 22 : 12,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(21),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (plan.badge != null) ...<Widget>[
                    Align(
                      alignment: Alignment.centerRight,
                      child: _PlanBadge(label: plan.badge!, color: accent),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: .11),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          switch (plan.type) {
                            StorePlanType.free => Icons.groups_rounded,
                            StorePlanType.monthly =>
                              Icons.workspace_premium_rounded,
                            StorePlanType.yearly => Icons.diamond_rounded,
                          },
                          color: accent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              plan.name,
                              style: AppTextStyle.textLg(
                                color: colors.onSurface,
                                weight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              plan.description,
                              style: AppTextStyle.textXs(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            plan.isPaid ? (storePrice ?? 'Unavailable') : r'$0',
                            style: AppTextStyle.textLg(
                              color: colors.onSurface,
                              weight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            plan.type == StorePlanType.free
                                ? plan.period
                                : 'per ${plan.period}',
                            style: AppTextStyle.textXs(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ...plan.features.map(
                    (String feature) => SubscriptionFeatureItem(
                      label: feature,
                      compact: true,
                      accentColor: accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: AppTextStyle.textXs(color: color, weight: FontWeight.w700),
      ),
    );
  }
}
