import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Search field placeholder (matches [CommunitySearchBar] / [CustomTextField]).
class CommunitySearchFieldSkeleton extends StatelessWidget {
  const CommunitySearchFieldSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonBox(width: double.infinity, height: 50, radius: 12);
  }
}

/// Collapsed feed composer placeholder (matches [PostInputField]).
class CommunityPostInputSkeleton extends StatelessWidget {
  const CommunityPostInputSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final outline = context.colorScheme.outline;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outline),
      ),
      child: const Row(
        children: [
          Expanded(child: SkeletonBox(width: double.infinity, height: 14, radius: 4)),
          SizedBox(width: 12),
          SkeletonBox(width: 24, height: 24, radius: 12),
        ],
      ),
    );
  }
}

class CommunityUserHeaderSkeleton extends StatelessWidget {
  const CommunityUserHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(width: 40, height: 40, radius: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 140, height: 14, radius: 4),
              SizedBox(height: 6),
              SkeletonBox(width: 90, height: 11, radius: 4),
            ],
          ),
        ),
      ],
    );
  }
}

class CommunityInteractionBarSkeleton extends StatelessWidget {
  const CommunityInteractionBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(width: 56, height: 22, radius: 6),
        SizedBox(width: 20),
        SkeletonBox(width: 72, height: 22, radius: 6),
      ],
    );
  }
}

/// Matches [PostCardWidget] / feed question cards.
class CommunityFeedPostSkeleton extends StatelessWidget {
  const CommunityFeedPostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = context.colorScheme.surfaceContainer;

    return Card(
      color: surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunityUserHeaderSkeleton(),
            SizedBox(height: 20),
            SkeletonBox(width: double.infinity, height: 12, radius: 4),
            SizedBox(height: 8),
            SkeletonBox(width: double.infinity, height: 12, radius: 4),
            SizedBox(height: 8),
            SkeletonBox(width: 180, height: 12, radius: 4),
            SizedBox(height: 20),
            CommunityInteractionBarSkeleton(),
          ],
        ),
      ),
    );
  }
}

/// Matches [CommunityOfferCard].
class CommunityOfferCardSkeleton extends StatelessWidget {
  const CommunityOfferCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = context.colorScheme.surfaceContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunityUserHeaderSkeleton(),
            SizedBox(height: 12),
            SkeletonBox(width: double.infinity, height: 12, radius: 4),
            SizedBox(height: 6),
            SkeletonBox(width: 220, height: 12, radius: 4),
            SizedBox(height: 12),
            SkeletonBox(width: double.infinity, height: 160, radius: 14),
            SizedBox(height: 14),
            CommunityInteractionBarSkeleton(),
          ],
        ),
      ),
    );
  }
}

/// Matches [CommunityNoticeCard].
class CommunityNoticeCardSkeleton extends StatelessWidget {
  const CommunityNoticeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = context.colorScheme.surfaceContainer;

    return Card(
      elevation: 1,
      color: surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunityUserHeaderSkeleton(),
            SizedBox(height: 16),
            SkeletonBox(width: double.infinity, height: 12, radius: 4),
            SizedBox(height: 8),
            SkeletonBox(width: 240, height: 12, radius: 4),
            SizedBox(height: 20),
            CommunityInteractionBarSkeleton(),
          ],
        ),
      ),
    );
  }
}

/// Matches [CommunityActivityCard] (header + description + embedded activity).
class CommunityActivityCardSkeleton extends StatelessWidget {
  const CommunityActivityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = context.colorScheme.surfaceContainer;

    return Card(
      elevation: 1,
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunityUserHeaderSkeleton(),
            SizedBox(height: 12),
            SkeletonBox(width: double.infinity, height: 12, radius: 4),
            SizedBox(height: 6),
            SkeletonBox(width: 200, height: 12, radius: 4),
            SizedBox(height: 16),
            SkeletonBox(width: double.infinity, height: 100, radius: 12),
            SizedBox(height: 16),
            CommunityInteractionBarSkeleton(),
          ],
        ),
      ),
    );
  }
}
