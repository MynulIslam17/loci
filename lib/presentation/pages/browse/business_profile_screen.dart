import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/browse_business/review_preview_controller.dart';
import 'package:loci/presentation/pages/browse/widgets/business_profile/business_header.dart';
import 'package:loci/presentation/pages/browse/widgets/business_profile/business_logo.dart';
import 'package:loci/presentation/pages/browse/widgets/business_profile/business_profile_shimmer.dart';
import 'package:loci/presentation/pages/browse/widgets/business_profile/business_rating.dart';
import 'package:loci/presentation/pages/browse/widgets/business_profile/photo_grid.dart';
import 'package:loci/presentation/pages/browse/widgets/business_profile/review_box.dart';
import 'package:loci/presentation/pages/browse/widgets/business_profile/review_list.dart';
import 'package:loci/routes/app_routes.dart';

import '../../controllers/browse_business/business_profile_controller.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final profileController = Get.find<BusinessProfileController>();
  final reviewController = Get.find<ReviewPreviewController>();
  late final String businessId;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;
    businessId = args?['businessId'] ?? '';

    // CALL BOTH APIs
    profileController.getBusinessProfile(businessId);
    reviewController.fetchReviews(businessId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Business profile",
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<BusinessProfileController>(
        builder: (controller) {
          if (controller.isLoading) {
            return BusinessProfileShimmer();
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          final business = controller.business;
          if (business == null) {
            return const Center(child: Text("No data found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                BusinessLogo(business.logo),
                const SizedBox(height: 24),

                BusinessHeaderSection(
                  name: business.name,
                  location: business.location,
                  phone: business.phone,
                  category: business.category,
                ),

                const SizedBox(height: 12),

                BusinessRating(
                  rating: business.rating,
                  reviewCount: business.reviewCount,
                ),

                const SizedBox(height: 24),

                _addToListButton(context),
                const SizedBox(height: 32),

                _description(context, business.description),
                const SizedBox(height: 32),

                _sectionTitle(context, "Photos"),
                const SizedBox(height: 6),

                PhotosGrid(business.photos),

                const SizedBox(height: 32),

                const ReviewBox(),
                const SizedBox(height: 32),

                _reviewsHeader(context),
                const SizedBox(height: 10),

                GetBuilder<ReviewPreviewController>(
                  builder: (reviewCtrl) {
                    if (reviewCtrl.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final reviews = reviewCtrl.getLimited(3);

                    if (reviews.isEmpty) {
                      return const Text("No reviews yet");
                    }

                    return ReviewList(reviews: reviews);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= METHODS (NO CLASSES) =================

  Widget _addToListButton(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 20),
        label: const Text("Add to List"),
      ),
    );
  }

  Widget _description(BuildContext context, String text) {
    return Card(
      color: context.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: AppTextStyle.textXs(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        title,
        style: AppTextStyle.textXl(
          weight: FontWeight.w700,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _reviewsHeader(BuildContext context) {
    return GetBuilder<ReviewPreviewController>(
      builder: (reviewCtrl) {
        final hasMoreThanThree = reviewCtrl.reviews.length > 3;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Reviews", style: AppTextStyle.textXl()),

            if (hasMoreThanThree)
              TextButton(
                onPressed: () {
                  Get.toNamed(
                    AppRoutes.allReviewScreen,
                    arguments: {"businessId": businessId},
                  );
                },
                child: const Text("View all"),
              ),
          ],
        );
      },
    );
  }
}
