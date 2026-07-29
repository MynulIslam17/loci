import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/features/browse_business/presentation/controllers/review_preview_controller.dart';
import 'package:loci/features/browse_business/presentation/widgets/review_list.dart';
import 'package:loci/features/browse_business/presentation/widgets/reviews_shimmer.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/empty_state.dart';

class BusinessProfileReviewsSection extends StatelessWidget {
  const BusinessProfileReviewsSection({
    super.key,
    required this.businessId,
    this.totalReviewCount,
  });

  final String businessId;

  /// From business profile when available; used with loaded list for "View all".
  final int? totalReviewCount;

  static const int _previewLimit = 3;

  @override
  Widget build(BuildContext context) {
    final reviewController = Get.find<ReviewPreviewController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final loaded = reviewController.reviews.length;
          final total = totalReviewCount ?? loaded;
          final isLoading =
              reviewController.isLoading.value && loaded == 0;
          final showViewAll = !isLoading &&
              loaded > 0 &&
              (loaded > _previewLimit || total > _previewLimit);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reviews', style: AppTextStyle.textXl()),
              if (showViewAll)
                TextButton(
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.allReviewScreen,
                      arguments: {'businessId': businessId},
                    );
                  },
                  child: const Text('View all'),
                ),
            ],
          );
        }),
        const SizedBox(height: 10),
        Obx(() {
          if (reviewController.isLoading.value &&
              reviewController.reviews.isEmpty) {
            return const ReviewsShimmer(itemCount: 2);
          }

          final reviews = reviewController.getLimited(_previewLimit);

          if (reviews.isEmpty) {
            return const EmptyState(
              icon: Icons.reviews_outlined,
              title: 'No reviews yet',
              subtitle: 'Be the first to leave a review.',
            );
          }

          return ReviewList(reviews: reviews);
        }),
      ],
    );
  }
}
