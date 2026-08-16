import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/features/my_business/presentation/controllers/business_review_controller.dart';
import 'package:loci/features/my_business/presentation/widgets/all_reviews_shimmer.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/review_card.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';

class MyBusinessAllReviewsScreen extends StatefulWidget {
  const MyBusinessAllReviewsScreen({super.key});

  @override
  State<MyBusinessAllReviewsScreen> createState() =>
      _MyBusinessAllReviewsScreenState();
}

class _MyBusinessAllReviewsScreenState
    extends State<MyBusinessAllReviewsScreen> {
  late final String _businessId;
  late final int _reviewCount;
  late final double _rating;
  late final MyBusinessReviewController reviewController;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _businessId = args?['businessId'] ?? '';
    _reviewCount = args?['reviewCount'] ?? 0;
    _rating = (args?['rating'] ?? 0.0).toDouble();
    reviewController = Get.find<MyBusinessReviewController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      reviewController.fetchReviews(_businessId, isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: CustomAppbar(title: "Reviews"),
      body: Obx(() {
        final ctrl = Get.find<MyBusinessReviewController>();
        // ── Loading ────────────────────────────────────────────────────
        if (ctrl.showInitialShimmer) return const AllReviewsShimmer();

        // ── Empty ──────────────────────────────────────────────────────
        if (ctrl.reviews.isEmpty) {
          return const EmptyState(
            icon: Icons.rate_review_outlined,
            title: 'No reviews yet',
            subtitle: 'Customer reviews will appear here.',
          );
        }

        // ── List ───────────────────────────────────────────────────────
        return AdaptiveRefresh(
          onRefresh: () => ctrl.fetchReviews(_businessId, isRefresh: true),
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            controller: ctrl.scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            itemCount: ctrl.reviews.length + 2,
            itemBuilder: (context, index) {
              // Header
              if (index == 0) return _buildRatingHeader(context);

              // Pagination loader
              final reviewIndex = index - 1;
              if (reviewIndex == ctrl.reviews.length) {
                return ctrl.isPaginationLoading
                    ? const PaginationLoader()
                    : const SizedBox.shrink();
              }

              // Review card
              final review = ctrl.reviews[reviewIndex];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ReviewCard(
                  name: review.author.name,
                  rating: review.rating.toDouble(),
                  reviewText: review.content,
                  imageUrl: review.author.avatar,
                  time: formatRelativeTime(review.createdAt),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  // ── Rating header ─────────────────────────────────────────────────────────

  Widget _buildRatingHeader(BuildContext context) {
    final scheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              if (_rating >= i + 1) {
                return const Icon(
                  Icons.star_rounded,
                  color: AppColors.starColor,
                  size: 22,
                );
              } else if (_rating > i) {
                return const Icon(
                  Icons.star_half_rounded,
                  color: AppColors.starColor,
                  size: 22,
                );
              } else {
                return Icon(
                  Icons.star_outline_rounded,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 22,
                );
              }
            }),
          ),
          const SizedBox(width: 8),
          Text(
            _rating.toStringAsFixed(1),
            style: AppTextStyle.textLg(
              weight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($_reviewCount ${_reviewCount == 1 ? 'review' : 'reviews'})',
            style: AppTextStyle.textSm(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
