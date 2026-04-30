import 'package:flutter/material.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';

class ReviewsShimmer extends StatelessWidget {
  final int itemCount;

  const ReviewsShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// PROFILE IMAGE
                AppSkeleton.box(
                  width: 45,
                  height: 45,
                  radius: 22.5,
                ),

                const SizedBox(width: 12),

                /// TEXT AREA
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeleton.box(height: 12, width: 120),
                        const SizedBox(height: 6),
                        AppSkeleton.box(height: 10, width: double.infinity),
                        const SizedBox(height: 6),
                        AppSkeleton.box(height: 10, width: 180),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}