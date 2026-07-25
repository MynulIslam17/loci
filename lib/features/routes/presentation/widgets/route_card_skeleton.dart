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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: double.infinity, height: 180, radius: 0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.box(width: 180, height: 16),
                const SizedBox(height: 10),
                AppSkeleton.box(width: double.infinity, height: 10),
                const SizedBox(height: 6),
                AppSkeleton.box(width: 220, height: 10),
                const SizedBox(height: 18),
                Row(
                  children: const [
                    Expanded(child: _InfoSkeleton()),
                    Expanded(child: _InfoSkeleton()),
                    Expanded(child: _InfoSkeleton()),
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

class _InfoSkeleton extends StatelessWidget {
  const _InfoSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        SkeletonBox(width: 14, height: 14, radius: 4),
        SizedBox(width: 4),
        Expanded(child: SkeletonBox(width: double.infinity, height: 10)),
      ],
    );
  }
}
