import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

class RaffleCardSkeleton extends StatelessWidget {
  const RaffleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: double.infinity, height: 180, radius: 0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.box(width: 200, height: 16),
                const SizedBox(height: 10),
                AppSkeleton.box(width: double.infinity, height: 10),
                const SizedBox(height: 6),
                AppSkeleton.box(width: 240, height: 10),
                const SizedBox(height: 16),
                const SkeletonBox(
                  width: double.infinity,
                  height: 44,
                  radius: 12,
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    SkeletonBox(width: 14, height: 14, radius: 4),
                    SizedBox(width: 6),
                    SkeletonBox(width: 160, height: 10),
                  ],
                ),
                const SizedBox(height: 16),
                const SkeletonBox(
                  width: double.infinity,
                  height: 48,
                  radius: 12,
                ),
                const SizedBox(height: 12),
                Center(child: AppSkeleton.box(width: 120, height: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
