import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

class MeetingShimmer extends StatelessWidget {
  const MeetingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (_, __) => const _MeetingCardShimmer(),
      separatorBuilder: (_, __) => const SizedBox(height: 15),
    );
  }
}

class _MeetingCardShimmer extends StatelessWidget {
  const _MeetingCardShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Card(
      color: colors.surfaceContainerHigh,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppSkeleton.box(width: 80, height: 28, radius: 8),
                AppSkeleton.box(width: 90, height: 11, radius: 4),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton.box(width: 100, height: 13, radius: 4),
                      const SizedBox(height: 6),
                      AppSkeleton.box(width: 70, height: 10, radius: 4),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: AppSkeleton.box(width: 20, height: 20, radius: 4),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppSkeleton.box(width: 100, height: 13, radius: 4),
                      const SizedBox(height: 6),
                      AppSkeleton.box(width: 70, height: 10, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppSkeleton.box(
                    height: 12,
                    width: double.infinity,
                    radius: 4,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppSkeleton.box(
                    height: 12,
                    width: double.infinity,
                    radius: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton.box(
                    height: 11,
                    width: double.infinity,
                    radius: 4,
                  ),
                  const SizedBox(height: 8),
                  AppSkeleton.box(height: 11, width: 160, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
