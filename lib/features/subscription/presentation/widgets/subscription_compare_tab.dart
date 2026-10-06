import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/store_subscription_plan.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_information_card.dart';

class SubscriptionCompareTab extends StatelessWidget {
  const SubscriptionCompareTab({super.key, required this.plans});

  final List<StoreSubscriptionPlan> plans;

  static const List<_ComparisonRowData> _features = <_ComparisonRowData>[
    _ComparisonRowData('Business Community', <String>['—', '✓', '✓']),
    _ComparisonRowData('Events', <String>['—', '✓', '✓']),
    _ComparisonRowData('Routes', <String>['—', '✓', '✓']),
    _ComparisonRowData('Raffles', <String>['—', '✓', '✓']),
    _ComparisonRowData('Spotlight Ads', <String>['—', '✓', '✓']),
    _ComparisonRowData('Spotlight Credits', <String>[
      '0',
      '100/month',
      '100/month',
    ]),
    _ComparisonRowData('Claim Business Profile', <String>['✓', '✓', '✓']),
    _ComparisonRowData('Ask & Answer Questions', <String>['✓', '✓', '✓']),
    _ComparisonRowData('Comment & Reviews', <String>['—', '✓', '✓']),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              children: <Widget>[
                _ComparisonRow(
                  title: 'Feature',
                  values: plans
                      .map((StoreSubscriptionPlan p) => p.name)
                      .toList(),
                  isHeader: true,
                ),
                ..._features.map(
                  (_ComparisonRowData item) =>
                      _ComparisonRow(title: item.title, values: item.values),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SubscriptionInformationCard(
            icon: Icons.campaign_rounded,
            title: 'About Spotlight Credits',
            body:
                'Both paid plans include 100 Spotlight credits per month. Each Spotlight Ad uses 10 credits, allowing up to 10 included Spotlight Ads per month.',
          ),
          const SizedBox(height: 12),
          const SubscriptionInformationCard(
            icon: Icons.groups_rounded,
            title: 'Business Owner Access',
            body:
                'One active paid subscription is linked to your account. Paid features and Spotlight credits can be used across all businesses you manage.',
          ),
          const SizedBox(height: 12),
          const SubscriptionInformationCard(
            icon: Icons.credit_card_rounded,
            title: 'Payments & Renewals',
            body:
                'iPhone subscriptions are purchased through the Apple App Store. Android subscriptions are purchased through Google Play. Monthly plans renew every month and yearly plans renew every year unless canceled.',
          ),
        ],
      ),
    );
  }
}

class _ComparisonRowData {
  const _ComparisonRowData(this.title, this.values);
  final String title;
  final List<String> values;
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.title,
    required this.values,
    this.isHeader = false,
  });

  final String title;
  final List<String> values;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;
    final bool isCreditRow = title == 'Spotlight Credits';
    return Container(
      constraints: BoxConstraints(minHeight: isHeader ? 62 : 39),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: .55),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 19,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                title,
                style: AppTextStyle.textXs(
                  color: colors.onSurface,
                  weight: isHeader ? FontWeight.w800 : FontWeight.w500,
                ).copyWith(fontSize: 11, height: 1.15),
              ),
            ),
          ),
          ...values.asMap().entries.map((MapEntry<int, String> entry) {
            final int index = entry.key;
            final String value = entry.value;
            final Color accent = index == 0
                ? const Color(0xFF6B7280)
                : index == 1
                ? const Color(0xFF0866E8)
                : const Color(0xFF249C43);
            return Expanded(
              flex: 11,
              child: Container(
                constraints: BoxConstraints(minHeight: isHeader ? 62 : 39),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: index == 0 ? .035 : .065),
                  border: Border(
                    left: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: .55),
                    ),
                  ),
                ),
                child: isHeader
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            index == 0
                                ? Icons.groups_rounded
                                : index == 1
                                ? Icons.workspace_premium_rounded
                                : Icons.diamond_rounded,
                            size: 18,
                            color: accent,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            value,
                            style: AppTextStyle.textXs(
                              color: colors.onSurface,
                              weight: FontWeight.w700,
                            ).copyWith(fontSize: 11),
                          ),
                        ],
                      )
                    : isCreditRow
                    ? Text(
                        value,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.textXs(
                          color: colors.onSurface,
                          weight: FontWeight.w600,
                        ).copyWith(fontSize: 10, height: 1.1),
                      )
                    : Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: value == '✓'
                              ? accent
                              : const Color(0xFFD7D9DD),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          value == '✓'
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          color: value == '✓'
                              ? Colors.white
                              : const Color(0xFF6B7280),
                          size: 13,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
