import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/presentation/controllers/browse_business/all_reviews_controller.dart';
import 'package:loci/presentation/pages/browse/widgets/business_profile/review_list.dart';
import 'package:loci/presentation/pages/browse/widgets/business_profile/reviews_shimmer.dart';

class AllReviewsScreen extends StatelessWidget {
  const AllReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Reviews")),
      body: GetBuilder<AllReviewsController>(
        initState: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final args = Get.arguments as Map<String, dynamic>;
            final businessId = args['businessId'] as String;
            Get.find<AllReviewsController>().init(businessId);
          });
        },
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return ReviewsShimmer(itemCount: 5,);
          }

          if (ctrl.reviews.isEmpty) {
            return const Center(child: Text("No reviews yet"));
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (!ctrl.isPaginationLoading &&
                  ctrl.hasMore &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                ctrl.loadMore();
              }
              return false;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ReviewList(reviews: ctrl.reviews),
                if (ctrl.isPaginationLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}