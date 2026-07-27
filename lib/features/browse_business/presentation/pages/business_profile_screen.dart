import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/browse_business/presentation/controllers/business_profile_controller.dart';
import 'package:loci/features/browse_business/presentation/controllers/post_review_controller.dart';
import 'package:loci/features/browse_business/presentation/controllers/review_preview_controller.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_header.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_logo.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_profile_reviews_section.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_profile_sections.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_profile_shimmer.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_rating.dart';
import 'package:loci/features/browse_business/presentation/widgets/photo_grid.dart';
import 'package:loci/features/browse_business/presentation/widgets/review_box.dart';
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
  final postReviewController = Get.find<PostReviewController>();
  late final String businessId;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;
    businessId = args?['businessId'] ?? '';

    profileController.getBusinessProfile(businessId);
    reviewController.fetchReviews(businessId);
  }

  Future<void> _refresh() async {
    await Future.wait([
      profileController.getBusinessProfile(businessId),
      reviewController.fetchReviews(businessId, showLoading: false),
    ]);
  }

  Future<bool> _submitReview(String content, double rating) async {
    final success = await postReviewController.postReview(
      businessId: businessId,
      rating: rating,
      content: content,
    );

    if (success) {
      SnackbarService.success(
        postReviewController.successMessage.value ??
            'Thank you for your feedback!',
      );
    } else {
      SnackbarService.error(
        postReviewController.errorMessage.value ??
            'Could not submit review. Please try again.',
      );
    }
    return success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppbar(title: 'Business Profile'),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Obx(() {
          if (profileController.isLoading.value) {
            return const BusinessProfileShimmer();
          }

          if (profileController.errorMessage.value != null) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ErrorStateWidget(
                  message: profileController.errorMessage.value!,
                  onRetry: () => profileController.getBusinessProfile(businessId),
                ),
              ],
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
                  title: 'Business not found',
                  subtitle: 'It may have been removed. Pull to refresh.',
                ),
              ],
            );
          }

          return _BusinessProfileContent(
            business: business,
            businessId: businessId,
            onSubmitReview: _submitReview,
          );
        }),
      ),
    );
  }
}

class _BusinessProfileContent extends StatelessWidget {
  const _BusinessProfileContent({
    required this.business,
    required this.businessId,
    required this.onSubmitReview,
  });

  final BrowseBusinessModel business;
  final String businessId;
  final Future<bool> Function(String content, double rating) onSubmitReview;

  @override
  Widget build(BuildContext context) {
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
          BusinessSaveListButton(businessId: businessId),
          const SizedBox(height: 32),
          BusinessDescriptionCard(description: business.description),
          const SizedBox(height: 32),
          const BusinessSectionTitle(title: 'Photos'),
          const SizedBox(height: 6),
          PhotosGrid(business.photos),
          const SizedBox(height: 32),
          ReviewBox(onSubmit: onSubmitReview),
          const SizedBox(height: 32),
          BusinessProfileReviewsSection(businessId: businessId),
        ],
      ),
    );
  }
}
