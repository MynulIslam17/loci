import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/my_business/presentation/controllers/business_review_controller.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/review_card.dart';

class MyBusinessReviewsPreview extends StatelessWidget {
  const MyBusinessReviewsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final reviewController = Get.find<MyBusinessReviewController>();

    return Obx(() {
      if (reviewController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (reviewController.reviews.isEmpty) {
        return const EmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No reviews yet',
          subtitle: 'When customers leave feedback, it will show up here.',
        );
      }

      return Column(
        children: reviewController.reviews.take(2).map((review) {
          return ReviewCard(
            name: review.author.name,
            businessName: '',
            rating: review.rating.toDouble(),
            reviewText: review.content,
            imageUrl: review.author.avatar,
            onMenuTap: () {},
          );
        }).toList(),
      );
    });
  }
}
