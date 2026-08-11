import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Full-page shimmer shown while the home feed is loading.
/// Mirrors the exact layout of the home screen:
///   1. Carousel banner
///   2. Activity row (Communities / Events / Raffles)
///   3. Post input field
///   4. Feed cards (post + poll variants)
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // ── 4. Feed cards ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _PostCardShimmer(hasPoll: false),
                _PostCardShimmer(hasPoll: true),
                _PostCardShimmer(hasPoll: false),
                _PostCardShimmer(hasPoll: true),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// . Single post card shimmer
//    [hasPoll] alternates between a plain text card and a poll card
// ─────────────────────────────────────────────────────────────────────────────
class _PostCardShimmer extends StatelessWidget {
  final bool hasPoll;

  const _PostCardShimmer({this.hasPoll = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Card(
      color: colors.surfaceContainer,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: avatar + name + date + category ──────────────────
            Row(
              children: [
                AppSkeleton.box(width: 40, height: 40, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppSkeleton.box(width: 120, height: 13, radius: 4),
                          const SizedBox(width: 8),
                          AppSkeleton.box(width: 60, height: 11, radius: 4),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AppSkeleton.box(width: 80, height: 10, radius: 4),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Post content text ─────────────────────────────────────────
            AppSkeleton.box(height: 12, width: double.infinity, radius: 4),
            const SizedBox(height: 8),
            AppSkeleton.box(height: 12, width: double.infinity, radius: 4),
            const SizedBox(height: 8),
            AppSkeleton.box(height: 12, width: 200, radius: 4),

            // ── Poll bars (only for poll cards) ───────────────────────────
            if (hasPoll) ...[
              const SizedBox(height: 20),
              _PollBarShimmer(),
              const SizedBox(height: 10),
              _PollBarShimmer(width: 0.75),
            ],

            const SizedBox(height: 20),

            // ── Interaction bar: like + comment ───────────────────────────
            Row(
              children: [
                AppSkeleton.box(width: 18, height: 18, radius: 4),
                const SizedBox(width: 6),
                AppSkeleton.box(width: 28, height: 12, radius: 4),
                const SizedBox(width: 16),
                AppSkeleton.box(width: 18, height: 18, radius: 4),
                const SizedBox(width: 6),
                AppSkeleton.box(width: 28, height: 12, radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Poll bar shimmer  (matches PollBar layout: label left, progress bar)
// ─────────────────────────────────────────────────────────────────────────────
class _PollBarShimmer extends StatelessWidget {
  /// Fraction of the screen width to fill (simulates different fill levels)
  final double width;

  const _PollBarShimmer({this.width = 1.0});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            AppSkeleton.box(width: 24, height: 24, radius: 4),
            const SizedBox(width: 10),
            Expanded(child: AppSkeleton.box(height: 12, radius: 4)),
            const SizedBox(width: 10),
            AppSkeleton.box(width: 36, height: 12, radius: 4),
          ],
        ),
      ),
    );
  }
}
