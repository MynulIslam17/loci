import 'package:flutter/material.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';

class CommunitySkeleton {
  CommunitySkeleton._();

  /// Matches the layout: Circle Image (Top Left), Text (Right), Description & Category (Below)
  static Widget card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.grey.shade900 : Colors.white;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),

      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Row: Circle Image + Name/Count ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Left Circle Image Shimmer
                const SkeletonBox(width: 48, height: 48, radius: 24),
                const SizedBox(width: 12),

                // Name and Member Count to the right of image
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Shimmer
                    const SkeletonBox(width: 140, height: 16, radius: 4),
                    const SizedBox(height: 6),
                    // Member Count Shimmer
                    const SkeletonBox(width: 80, height: 12, radius: 4),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- Below: Description ---
            const SkeletonBox(width: double.infinity, height: 12, radius: 2),
            const SizedBox(height: 6),
            const SkeletonBox(width: 220, height: 12, radius: 2),

            const SizedBox(height: 16),

            // --- Bottom: Category ---
            const SkeletonBox(width: 70, height: 14, radius: 4),
          ],
        ),
      ),
    );
  }

  /// Helper to build a list of shimmers
  static Widget list({int count = 3}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) => card(context),
    );
  }
}