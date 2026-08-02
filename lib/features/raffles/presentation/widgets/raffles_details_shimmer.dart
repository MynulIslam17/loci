import 'package:flutter/material.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_detail_scroll.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_detail_shimmer.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Loading layout for participant [RafflesDetailsScreen].
class RafflesDetailsShimmer extends StatelessWidget {
  const RafflesDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: ExploreActivityDetailScroll.padding,
      children: [
        const ExploreActivitySectionShimmer(
          child: _CoverShimmer(),
        ),
        ExploreActivitySectionShimmer(
          showTitle: true,
          child: AppSkeleton.box(height: 48, radius: 12),
        ),
        ExploreActivitySectionShimmer(
          showTitle: true,
          child: Column(
            children: [
              AppSkeleton.box(height: 10, radius: 8),
              const SizedBox(height: 12),
              AppSkeleton.box(height: 48, radius: 16),
              const SizedBox(height: 12),
              AppSkeleton.box(height: 48, radius: 16),
            ],
          ),
        ),
        ExploreActivitySectionShimmer(
          showTitle: true,
          showSubtitle: true,
          child: Column(
            children: [
              AppSkeleton.box(height: 72, radius: 16),
              const SizedBox(height: 8),
              AppSkeleton.box(height: 72, radius: 16),
            ],
          ),
        ),
        ExploreActivitySectionShimmer(
          showTitle: true,
          child: AppSkeleton.box(height: 72, radius: 14),
        ),
      ],
    );
  }
}

class _CoverShimmer extends StatelessWidget {
  const _CoverShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton.box(height: 200, radius: 12),
        const SizedBox(height: 16),
        AppSkeleton.box(width: 220, height: 18, radius: 4),
        const SizedBox(height: 8),
        AppSkeleton.box(width: 280, height: 12, radius: 4),
        const SizedBox(height: 8),
        AppSkeleton.box(width: 180, height: 12, radius: 4),
      ],
    );
  }
}
