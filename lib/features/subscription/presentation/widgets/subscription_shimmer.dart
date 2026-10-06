import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Skeleton that mirrors the My Subscription layout (plan + credits + billing).
class MySubscriptionShimmer extends StatelessWidget {
  const MySubscriptionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MySubHeroShimmer(),
          const SizedBox(height: 16),
          const _MySubSectionShimmer(lines: 2),
          const SizedBox(height: 16),
          const _MySubSectionShimmer(lines: 3),
          const SizedBox(height: 24),
          AppSkeleton.box(width: double.infinity, height: 48, radius: 12),
        ],
      ),
    );
  }
}

class _MySubHeroShimmer extends StatelessWidget {
  const _MySubHeroShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSkeleton.box(width: 44, height: 44, radius: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton.box(width: 140, height: 18),
                    const SizedBox(height: 10),
                    AppSkeleton.box(width: 72, height: 22, radius: 20),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppSkeleton.box(width: 96, height: 28),
        ],
      ),
    );
  }
}

class _MySubSectionShimmer extends StatelessWidget {
  const _MySubSectionShimmer({required this.lines});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < lines; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            Row(
              children: [
                AppSkeleton.box(width: 18, height: 18, radius: 4),
                const SizedBox(width: 12),
                AppSkeleton.box(width: 80, height: 12),
                const Spacer(),
                AppSkeleton.box(width: 90, height: 12),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
