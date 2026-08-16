import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

class RaffleCardSkeleton extends StatelessWidget {
  const RaffleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: isDark ? 0.3 : 0.15),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Compact Hero Image Placeholder
          Stack(
            children: const [
              SkeletonBox(width: double.infinity, height: 135, radius: 0),
              Positioned(
                top: 10,
                left: 10,
                child: SkeletonBox(width: 60, height: 22, radius: 12),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: SkeletonBox(width: 70, height: 22, radius: 16),
              ),
            ],
          ),

          // 2. Content Body Skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Organizer Row
                Row(
                  children: const [
                    SkeletonBox(width: 18, height: 18, radius: 9),
                    SizedBox(width: 6),
                    SkeletonBox(width: 100, height: 10, radius: 4),
                  ],
                ),
                const SizedBox(height: 6),

                // Title
                const SkeletonBox(width: 220, height: 16, radius: 4),
                const SizedBox(height: 4),

                // Description
                const SkeletonBox(width: double.infinity, height: 10, radius: 4),
                const SizedBox(height: 8),

                // Date Row
                Row(
                  children: const [
                    SkeletonBox(width: 14, height: 14, radius: 3),
                    SizedBox(width: 6),
                    SkeletonBox(width: 140, height: 10, radius: 4),
                  ],
                ),
                const SizedBox(height: 10),

                // Button Skeleton
                const SkeletonBox(width: double.infinity, height: 40, radius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

