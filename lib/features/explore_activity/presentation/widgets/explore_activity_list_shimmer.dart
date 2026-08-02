import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Shimmer placeholders for Explore Activity tabs (events, routes, raffles).
class ExploreActivityListShimmer {
  ExploreActivityListShimmer._();

  static Widget sliver({int itemCount = 4}) {
    return SliverList.separated(
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => const _ExploreActivityCardShimmer(),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeleton.box(width: 200, height: 14, radius: 4),
                          const SizedBox(height: 6),
                          AppSkeleton.box(width: 150, height: 14, radius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppSkeleton.box(width: 56, height: 22, radius: 20),
                  ],
                ),
                const SizedBox(height: 8),
                AppSkeleton.box(width: double.infinity, height: 11, radius: 4),
                const SizedBox(height: 6),
                AppSkeleton.box(width: 220, height: 11, radius: 4),
                const SizedBox(height: 12),
                const _MetaRowSkeleton(twoLines: true),
                const SizedBox(height: 8),
                const _MetaRowSkeleton(),
                const SizedBox(height: 8),
                const _MetaRowSkeleton(),
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

class _MetaRowSkeleton extends StatelessWidget {
  const _MetaRowSkeleton({this.twoLines = false});

  final bool twoLines;

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
              if (twoLines) ...[
                const SizedBox(height: 4),
                AppSkeleton.box(width: 180, height: 10, radius: 4),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
