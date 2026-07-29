import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Shimmer for owner (cards + button) or member (+ map) community headers.
class CommunityOwnerHeaderShimmer extends StatelessWidget {
  const CommunityOwnerHeaderShimmer({
    super.key,
    this.showIdentity = false,
    this.showMapPreview = false,
  });

  final bool showIdentity;
  final bool showMapPreview;

  @override
  Widget build(BuildContext context) {
    final surfaceHigh = Theme.of(context).colorScheme.surfaceContainerHigh;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showIdentity) ...[
          const SkeletonBox(width: 220, height: 22, radius: 6),
          const SizedBox(height: 10),
          const SkeletonBox(width: double.infinity, height: 16, radius: 4),
          const SizedBox(height: 16),
        ],
        if (showMapPreview) ...[
          const SkeletonBox(width: double.infinity, height: 150, radius: 16),
        ] else ...[
          Row(
            children: [
              Expanded(child: _actionCard(surfaceHigh)),
              const SizedBox(width: 12),
              Expanded(child: _actionCard(surfaceHigh)),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonBox(width: double.infinity, height: 54, radius: 8),
        ],
      ],
    );
  }

  Widget _actionCard(Color cardColor) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            SkeletonBox(width: 80, height: 26, radius: 4),
            SizedBox(height: 10),
            SkeletonBox(width: 72, height: 14, radius: 4),
          ],
        ),
      ),
    );
  }
}
