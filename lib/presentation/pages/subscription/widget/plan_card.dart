import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/data/models/subscription/plan_response_model.dart';

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool isExpanded;
  final bool isMonthly;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isExpanded,
    required this.isMonthly,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isFree = plan.amount == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.name,
              style: AppTextStyle.textSm(
                color: colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              isFree
                  ? "Free"
                  : "\$${plan.amount}${isMonthly ? '/month' : ''}",
              style: AppTextStyle.textXl(
                color: colorScheme.primary,
                weight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              plan.features.join(", "),
              style: AppTextStyle.textXs(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded ? "Hide benefits" : "See benefits",
                    style: AppTextStyle.textSm(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                ],
              ),
            ),

            AnimatedCrossFade(
              firstChild: const SizedBox(),
              secondChild: Column(
                children: plan.features
                    .map(
                      (e) => Row(
                    children: [
                      Icon(Icons.check,
                          size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e)),
                    ],
                  ),
                )
                    .toList(),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(isFree ? "Join Free" : "Subscribe"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}