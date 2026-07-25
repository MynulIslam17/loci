import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/presentation/widgets/active_plan_banner.dart';

/// Headline + active-plan banner that sit above the pinned billing toggle and
/// scroll away with the content.
class SubscriptionHeader extends StatelessWidget {
  const SubscriptionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grow your business',
                style: AppTextStyle.textXl(
                  color: colorScheme.onSurface,
                  weight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick a plan that fits — cancel anytime.',
                style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const ActivePlanBanner(),
        const SizedBox(height: 10),
      ],
    );
  }
}
