import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/browse_business/presentation/controllers/post_review_controller.dart';
import 'package:loci/features/browse_business/presentation/controllers/review_preview_controller.dart';
import 'package:loci/features/browse_business/presentation/controllers/save_business_controller.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_profile/business_header.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_profile/business_logo.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_profile/business_profile_shimmer.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_profile/business_rating.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_profile/photo_grid.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_profile/review_box.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_profile/review_list.dart';
import 'package:loci/routes/app_routes.dart';

import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/browse_business/presentation/controllers/business_profile_controller.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final profileController = Get.find<BusinessProfileController>();
  final reviewController = Get.find<ReviewPreviewController>();
  final saveController = Get.find<SaveBusinessController>();
  final postReviewController = Get.find<PostReviewController>();
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

  Future<void> _refresh() async {
    await Future.wait([
      profileController.getBusinessProfile(businessId),
      reviewController.fetchReviews(businessId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: CustomAppbar(title: "Business Profile"),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Obx(() {
        if (profileController.isLoading.value) {
          return BusinessProfileShimmer();
        }

        if (profileController.errorMessage.value != null) {
          return ErrorStateWidget(
            message: profileController.errorMessage.value!,
            onRetry: () => profileController.getBusinessProfile(businessId),
          );
        }

        final business = profileController.business.value;
        if (business == null) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 100),
              EmptyState(
                icon: Icons.storefront_outlined,
                title: "Business not found",
                subtitle: "It may have been removed. Pull to refresh.",
              ),
            ],
          );
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              ReviewBox(
                onSubmit: (String content, double rating) async {
                  final success = await postReviewController.postReview(
                    businessId: businessId,
                    rating: rating,
                    content: content,
                  );

                  if (success) {
                    SnackbarService.success('Thank you for your feedback!');
                  } else {
                    SnackbarService.error(
                      'Could not submit review. Please try again.',
                    );
                  }
                },
              ),
              const SizedBox(height: 32),

              _reviewsHeader(context),
              const SizedBox(height: 10),

              Obx(() {
                if (reviewController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reviews = reviewController.getLimited(3);

                if (reviews.isEmpty) {
                  return const EmptyState(
                    icon: Icons.reviews_outlined,
                    title: "No reviews yet",
                    subtitle: "Be the first to leave a review.",
                  );
                }

                return ReviewList(reviews: reviews);
              }),
            ],
          ),
        );
        }),
      ),
    );
  }

  // ================= METHODS (NO CLASSES) =================
  Widget _addToListButton(BuildContext context) {
    return Obx(() {
      final loading = saveController.isLoading(businessId);

      return SizedBox(
        width: 180,
        height: 45,
        child: ElevatedButton.icon(
          onPressed: loading
              ? null
              : () => saveController.saveBusiness(businessId),

          icon: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add, size: 20),

          label: Text(loading ? "Saving..." : "Add to List"),
        ),
      );
    });
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
    return Obx(() {
      final hasMoreThanThree = reviewController.reviews.length > 3;

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
    });
  }
}
