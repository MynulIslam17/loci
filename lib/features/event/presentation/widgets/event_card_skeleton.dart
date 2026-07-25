import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: context.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: double.infinity, height: 200, radius: 10),
            const SizedBox(height: 16),
            AppSkeleton.box(width: 220, height: 18),
            const SizedBox(height: 10),
            AppSkeleton.box(width: double.infinity, height: 10),
            const SizedBox(height: 6),
            AppSkeleton.box(width: 260, height: 10),
            const SizedBox(height: 16),
            const _IconRowSkeleton(),
            const SizedBox(height: 8),
            const _IconRowSkeleton(),
            const SizedBox(height: 8),
            const _IconRowSkeleton(),
            const SizedBox(height: 20),
            const SkeletonBox(width: double.infinity, height: 48, radius: 12),
            const SizedBox(height: 12),
            Center(child: AppSkeleton.box(width: 120, height: 10)),
          ],
        ),
      ),
    );
  }
}

class _IconRowSkeleton extends StatelessWidget {
  const _IconRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        SkeletonBox(width: 18, height: 18, radius: 4),
        SizedBox(width: 8),
        Expanded(child: SkeletonBox(width: double.infinity, height: 10)),
      ],
    );
  }
}
