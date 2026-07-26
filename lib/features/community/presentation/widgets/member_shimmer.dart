import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

class MemberCardShimmer extends StatelessWidget {
  const MemberCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Card(
      color: colors.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            const SkeletonBox(width: 44, height: 44, radius: 22),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 140, height: 14, radius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 11, radius: 4),
                  SizedBox(height: 6),
                  SkeletonBox(width: 100, height: 11, radius: 4),
                  SizedBox(height: 6),
                  SkeletonBox(width: 120, height: 11, radius: 4),
                ],
              ),
            ),

            // Popup icon placeholder
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SkeletonBox(width: 20, height: 20, radius: 4),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberListShimmer extends StatelessWidget {
  final int count;

  const MemberListShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const MemberCardShimmer(),
          childCount: count,
        ),
      ),
    );
  }
}
