import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

class RouteCardSkeleton extends StatelessWidget {
  const RouteCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: double.infinity, height: 180, radius: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.box(width: 200, height: 14, radius: 4),
                const SizedBox(height: 6),
                AppSkeleton.box(width: 160, height: 14, radius: 4),
                const SizedBox(height: 8),
                AppSkeleton.box(width: double.infinity, height: 10, radius: 4),
                const SizedBox(height: 6),
                AppSkeleton.box(width: 220, height: 10, radius: 4),
                const SizedBox(height: 12),
                const _LocationRowSkeleton(),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: const [
                    _InfoChipSkeleton(width: 100),
                    _InfoChipSkeleton(width: 110),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationRowSkeleton extends StatelessWidget {
  const _LocationRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(width: 14, height: 14, radius: 4),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton.box(width: double.infinity, height: 10, radius: 4),
              const SizedBox(height: 4),
              AppSkeleton.box(width: 180, height: 10, radius: 4),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChipSkeleton extends StatelessWidget {
  const _InfoChipSkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SkeletonBox(width: 14, height: 14, radius: 4),
        const SizedBox(width: 4),
        SkeletonBox(width: width, height: 10, radius: 4),
      ],
    );
  }
}
