import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Shimmer skeleton loader for the Chat List screen.
class ChatListShimmer extends StatelessWidget {
  const ChatListShimmer({super.key, this.itemCount = 7});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ChatTileShimmer(),
    );
  }
}

/// Shimmer item mimicking a single chat conversation tile.
class ChatTileShimmer extends StatelessWidget {
  const ChatTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            const SkeletonBox(width: 55, height: 55, radius: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 120, height: 14, radius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 170, height: 11, radius: 4),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                SkeletonBox(width: 42, height: 10, radius: 4),
                SizedBox(height: 8),
                SkeletonBox(width: 16, height: 16, radius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
