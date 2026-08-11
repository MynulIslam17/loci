import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final cardWidth = MediaQuery.sizeOf(context).width * 0.85;

    return Column(
      children: [
        SizedBox(
          height: 208,
          child: Center(
            child: Container(
              width: cardWidth,
              height: 200,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppSkeleton.box(
                      width: double.infinity,
                      height: double.infinity,
                      radius: 15,
                    ),
                  ),
                  Positioned(
                    bottom: 22,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppSkeleton.box(width: 160, height: 14, radius: 4),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            AppSkeleton.box(width: 14, height: 14, radius: 7),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AppSkeleton.box(
                                width: double.infinity,
                                height: 10,
                                radius: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSkeleton.box(width: 27, height: 8, radius: 4),
            const SizedBox(width: 6),
            AppSkeleton.box(width: 10, height: 8, radius: 4),
            const SizedBox(width: 6),
            AppSkeleton.box(width: 10, height: 8, radius: 4),
          ],
        ),
      ],
    );
  }
}
