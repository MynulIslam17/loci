import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// A shimmer placeholder that mirrors the real [ReviewCard] layout.
/// Drop it inside any scroll view; it is non-scrollable on its own.
class ReviewCardShimmer extends StatelessWidget {
  /// Number of shimmer cards to render.
  final int itemCount;

  const ReviewCardShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Card(
        elevation: 2,
        color: scheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: avatar | name + time | stars ──────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar circle
                  AppSkeleton.box(width: 50, height: 50, radius: 25),

                  const SizedBox(width: 12),

                  // Name + time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeleton.box(height: 13, width: 130),
                        const SizedBox(height: 6),
                        AppSkeleton.box(height: 10, width: 80),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Stars row
                  Row(
                    children: List.generate(
                      5,
                      (_) => Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: AppSkeleton.box(
                          width: 14,
                          height: 14,
                          radius: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Review body text (3 lines) ──────────────────────────────
              AppSkeleton.box(height: 11, width: double.infinity),
              const SizedBox(height: 6),
              AppSkeleton.box(height: 11, width: double.infinity),
              const SizedBox(height: 6),
              AppSkeleton.box(height: 11, width: 220),
            ],
          ),
        ),
      ),
    );
  }
}
