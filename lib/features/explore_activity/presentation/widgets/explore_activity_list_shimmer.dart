import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Shimmer placeholders for Explore Activity tabs (events, routes, raffles).
class ExploreActivityListShimmer {
  ExploreActivityListShimmer._();

  static Widget sliver({int itemCount = 4}) {
    return SliverList.separated(
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const _ExploreActivityCardShimmer(),
    );
  }
}

class _ExploreActivityCardShimmer extends StatelessWidget {
  const _ExploreActivityCardShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Card(
      color: colors.surfaceContainerHigh,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton.box(height: 160, radius: 0),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.box(width: 180, height: 16, radius: 4),
                const SizedBox(height: 8),
                AppSkeleton.box(width: double.infinity, height: 11, radius: 4),
                const SizedBox(height: 6),
                AppSkeleton.box(width: 220, height: 11, radius: 4),
                const SizedBox(height: 12),
                AppSkeleton.box(width: 140, height: 11, radius: 4),
                const SizedBox(height: 8),
                AppSkeleton.box(width: 120, height: 11, radius: 4),
                const SizedBox(height: 8),
                AppSkeleton.box(width: 100, height: 11, radius: 4),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppSkeleton.box(height: 40, radius: 10),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppSkeleton.box(height: 40, radius: 10),
                    ),
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
