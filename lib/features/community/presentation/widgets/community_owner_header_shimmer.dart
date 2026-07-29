import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Matches [CommunityOwnerHeader] layout (two cards + announcement button).
class CommunityOwnerHeaderShimmer extends StatelessWidget {
  const CommunityOwnerHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final surfaceHigh = Theme.of(context).colorScheme.surfaceContainerHigh;
    final surface = Theme.of(context).colorScheme.surfaceContainer;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _actionCard(surfaceHigh, surface)),
            const SizedBox(width: 20),
            Expanded(child: _actionCard(surfaceHigh, surface)),
          ],
        ),
        const SizedBox(height: 10),
        const SkeletonBox(width: double.infinity, height: 48, radius: 8),
      ],
    );
  }

  Widget _actionCard(Color cardColor, Color iconBg) {
    return Card(
      elevation: 1,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SkeletonBox(width: 22, height: 22, radius: 4),
                  ),
                ),
                const SizedBox(width: 10),
                const SkeletonBox(width: 28, height: 14, radius: 4),
              ],
            ),
            const SizedBox(height: 10),
            const SkeletonBox(width: 72, height: 16, radius: 4),
          ],
        ),
      ),
    );
  }
}
