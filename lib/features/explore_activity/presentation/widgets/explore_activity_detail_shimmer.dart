import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_detail_scroll.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Shimmer block matching [ExploreActivitySection] chrome (border, padding).
class ExploreActivitySectionShimmer extends StatelessWidget {
  const ExploreActivitySectionShimmer({
    super.key,
    required this.child,
    this.showTitle = false,
    this.showSubtitle = false,
  });

  final Widget child;
  final bool showTitle;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            AppSkeleton.box(width: 160, height: 18, radius: 4),
            if (showSubtitle) ...[
              const SizedBox(height: 8),
              AppSkeleton.box(width: 240, height: 12, radius: 4),
            ],
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

/// Shared loading layout for view + edit activity screens (section-based UI).
class ExploreActivityDetailShimmer extends StatelessWidget {
  const ExploreActivityDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: ExploreActivityDetailScroll.padding,
      children: [
        const ExploreActivitySectionShimmer(
          showTitle: true,
          showSubtitle: true,
          child: _CoverShimmer(),
        ),
        const ExploreActivitySectionShimmer(
          showTitle: true,
          child: Column(
            children: [
              _ShimmerField(),
              SizedBox(height: 16),
              _ShimmerField(lines: 3),
            ],
          ),
        ),
        const ExploreActivitySectionShimmer(
          showTitle: true,
          showSubtitle: true,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _ShimmerField(compact: true)),
                  SizedBox(width: 12),
                  Expanded(child: _ShimmerField(compact: true)),
                ],
              ),
              SizedBox(height: 16),
              _ShimmerField(),
            ],
          ),
        ),
        ExploreActivitySectionShimmer(
          showTitle: true,
          child: Column(
            children: [
              const _ShimmerField(),
              const SizedBox(height: 16),
              const _ShimmerField(),
              const SizedBox(height: 16),
              AppSkeleton.box(height: 160, radius: 12),
            ],
          ),
        ),
        ExploreActivitySectionShimmer(
          showTitle: true,
          child: Column(
            children: [
              AppSkeleton.box(height: 48, radius: 12),
              const SizedBox(height: 16),
              AppSkeleton.box(height: 72, radius: 14),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: AppSkeleton.box(height: 48, radius: 10)),
                  const SizedBox(width: 12),
                  Expanded(child: AppSkeleton.box(height: 48, radius: 10)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverShimmer extends StatelessWidget {
  const _CoverShimmer();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton.box(height: 180, radius: 12);
  }
}

class _ShimmerField extends StatelessWidget {
  const _ShimmerField({
    this.compact = false,
    this.lines = 1,
  });

  final bool compact;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton.box(
          width: compact ? 72 : 96,
          height: 11,
          radius: 4,
        ),
        const SizedBox(height: 8),
        if (lines == 1)
          AppSkeleton.box(
            height: compact ? 44 : 48,
            radius: 10,
          )
        else
          AppSkeleton.box(
            height: compact ? 44 : 88,
            radius: 10,
          ),
      ],
    );
  }
}
