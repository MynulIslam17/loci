import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Full-screen loading placeholder for the connections screen
/// (search, header, and card list).
class ConnectionScreenShimmer extends StatelessWidget {
  const ConnectionScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _HeaderShimmer()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          sliver: SliverList.separated(
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const ConnectionCardShimmer(),
          ),
        ),
      ],
    );
  }
}

class _HeaderShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton.box(
            height: 48,
            width: double.infinity,
            radius: 12,
          ),
          const SizedBox(height: 16),
          AppSkeleton.box(width: 140, height: 22, radius: 6),
          const SizedBox(height: 8),
          AppSkeleton.box(width: 90, height: 14, radius: 4),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for a single connection card.
class ConnectionCardShimmer extends StatelessWidget {
  const ConnectionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton.box(width: 48, height: 48, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.box(width: 120, height: 14, radius: 4),
                const SizedBox(height: 8),
                AppSkeleton.box(width: 160, height: 10, radius: 4),
                const SizedBox(height: 6),
                AppSkeleton.box(width: 180, height: 10, radius: 4),
                const SizedBox(height: 6),
                AppSkeleton.box(width: 100, height: 10, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
