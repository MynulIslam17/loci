import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/browse_business/presentation/controllers/all_reviews_controller.dart';
import 'package:loci/features/browse_business/presentation/widgets/review_list.dart';
import 'package:loci/features/browse_business/presentation/widgets/reviews_shimmer.dart';
import 'package:loci/shared/widgets/empty_state.dart';

class AllReviewsScreen extends StatefulWidget {
  const AllReviewsScreen({super.key});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  final ctrl = Get.find<AllReviewsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>;
      ctrl.init(args['businessId'] as String);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Reviews')),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.reviews.isEmpty) {
          return ReviewsShimmer(itemCount: 5);
        }

        if (ctrl.reviews.isEmpty) {
          return const Center(
            child: EmptyState(
              icon: Icons.reviews_outlined,
              title: 'No reviews yet',
              subtitle: 'Be the first to leave a review.',
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!ctrl.isPaginationLoading.value &&
                ctrl.hasMore.value &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
              ctrl.loadMore();
            }
            return false;
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ReviewList(reviews: ctrl.reviews.toList()),
              if (ctrl.isPaginationLoading.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
