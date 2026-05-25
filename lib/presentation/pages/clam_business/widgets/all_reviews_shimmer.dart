import 'package:flutter/material.dart';
import 'package:loci/presentation/pages/clam_business/widgets/review_card_shimmer.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';

/// Full loading placeholder for the All-Reviews screen.
/// Renders a shimmer rating-header row followed by [itemCount] review-card skeletons.
class AllReviewsShimmer extends StatelessWidget {
  final int itemCount;

  const AllReviewsShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Rating header row ─────────────────────────────────────────
          Row(
            children: [
              // 5 star placeholders
              ...List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: AppSkeleton.box(width: 22, height: 22, radius: 4),
                ),
              ),
              const SizedBox(width: 8),
              // Numeric rating placeholder  e.g. "4.3"
              AppSkeleton.box(width: 36, height: 18, radius: 5),
              const SizedBox(width: 6),
              // Review count placeholder  e.g. "(24 reviews)"
              AppSkeleton.box(width: 90, height: 14, radius: 5),
            ],
          ),

          const SizedBox(height: 16),

          // ── Review card placeholders ──────────────────────────────────
          ReviewCardShimmer(itemCount: itemCount),
        ],
      ),
    );
  }
}
