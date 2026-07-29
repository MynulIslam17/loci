import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Shimmer placeholder matching the collapsed [ExpandableBusinessCard] on
/// [SearchMyBusiness] (logo, name, category, chevron in a bordered card).
class MyBusinessCardShimmer extends StatelessWidget {
  const MyBusinessCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: scheme.outline,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: const [
              SkeletonBox(width: 52, height: 52, radius: 10),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 160, height: 14, radius: 4),
                    SizedBox(height: 6),
                    SkeletonBox(width: 100, height: 11, radius: 4),
                  ],
                ),
              ),
              SizedBox(width: 8),
              SkeletonBox(width: 22, height: 22, radius: 4),
            ],
          ),
        ),
      ),
    );
  }
}
