import 'package:flutter/material.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';

import '../../../../core/theme/theme_extention.dart';

class BrowseShimmer extends StatelessWidget {
  const BrowseShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _ExpandedShimmerCard();
        }
        return const _CompactShimmerCard();
      },
    );
  }
}

class _ExpandedShimmerCard extends StatelessWidget {
  const _ExpandedShimmerCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme=context.colorScheme;
    return Card(
      color:colorScheme.surfaceContainerHigh ,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                AppSkeleton.box(width: 52, height: 52),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton.box(height: 12, width: 140),
                      const SizedBox(height: 6),
                      AppSkeleton.box(height: 10, width: 90),
                    ],
                  ),
                ),

                AppSkeleton.box(height: 20, width: 50),
                const SizedBox(width: 8),
                AppSkeleton.box(height: 18, width: 18),
              ],
            ),
          ),

          // IMAGE
          AppSkeleton.box(height: 160, width: double.infinity),

          const SizedBox(height: 10),

          // DESCRIPTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.box(height: 10, width: double.infinity),
                const SizedBox(height: 6),
                AppSkeleton.box(height: 10, width: double.infinity),
                const SizedBox(height: 6),
                AppSkeleton.box(height: 10, width: 180),

                const SizedBox(height: 12),

                // LOCATION
                Row(
                  children: [
                    AppSkeleton.box(height: 12, width: 12),
                    const SizedBox(width: 6),
                    AppSkeleton.box(height: 10, width: 140),
                  ],
                ),

                const SizedBox(height: 14),

                // BUTTONS
                Row(
                  children: [
                    Expanded(child: AppSkeleton.box(height: 38)),
                    const SizedBox(width: 10),
                    Expanded(child: AppSkeleton.box(height: 38)),
                  ],
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactShimmerCard extends StatelessWidget {
  const _CompactShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            AppSkeleton.box(width: 52, height: 52),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton.box(height: 12, width: 120),
                  const SizedBox(height: 6),
                  AppSkeleton.box(height: 10, width: 80),
                ],
              ),
            ),

            AppSkeleton.box(height: 20, width: 45),
            const SizedBox(width: 8),
            AppSkeleton.box(height: 18, width: 18),
          ],
        ),
      ),
    );
  }
}