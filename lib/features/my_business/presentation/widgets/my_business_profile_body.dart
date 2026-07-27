import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
import 'package:loci/features/my_business/presentation/controllers/my_business_profile_controller.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_ads_section.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_description_card.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_photo_grid.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_profile_header.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_reviews_preview.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_section_header.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_button.dart';

class MyBusinessProfileBody extends StatelessWidget {
  const MyBusinessProfileBody({
    super.key,
    required this.business,
    required this.profileImage,
    required this.localPhotos,
    required this.creditsRemaining,
    required this.onRefresh,
    required this.onEditBusinessTap,
    required this.onEditDescriptionTap,
    required this.onLogoPick,
    required this.onCommunityQrTap,
    required this.onAddPhotos,
    required this.onRemoveLocalPhoto,
    required this.onRemoveApiPhoto,
    required this.onCreateAdTap,
    required this.onViewAllReviewsTap,
  });

  final BusinessProfileModel business;
  final Rxn<File> profileImage;
  final RxList<File> localPhotos;
  final RxnInt creditsRemaining;
  final Future<void> Function() onRefresh;
  final VoidCallback onEditBusinessTap;
  final VoidCallback onEditDescriptionTap;
  final VoidCallback onLogoPick;
  final VoidCallback onCommunityQrTap;
  final void Function(List<File> files) onAddPhotos;
  final void Function(int localIndex) onRemoveLocalPhoto;
  final void Function(String photoUrl) onRemoveApiPhoto;
  final Future<void> Function() onCreateAdTap;
  final VoidCallback onViewAllReviewsTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final profileController = Get.find<MyBusinessProfileController>();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            MyBusinessProfileHeader(
              business: business,
              profileImage: profileImage,
              onEditBusinessTap: onEditBusinessTap,
              onLogoPick: onLogoPick,
              onCommunityQrTap: onCommunityQrTap,
            ),
            const SizedBox(height: 20),
            MyBusinessDescriptionCard(
              description: business.description,
              onEditTap: onEditDescriptionTap,
            ),
            const SizedBox(height: 25),
            const MyBusinessSectionHeader(title: 'Photos'),
            MyBusinessPhotoGrid(
              apiPhotos: business.photos,
              localPhotos: localPhotos,
              onAddPhotos: onAddPhotos,
              onRemoveLocalPhoto: onRemoveLocalPhoto,
              onRemoveApiPhoto: onRemoveApiPhoto,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Explore Activities',
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Get.toNamed(
                  AppRoutes.exploreActivity,
                  arguments: {
                    'businessName': business.name,
                    'businessId': business.id,
                  },
                );
              },
              textStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 25),
            const MyBusinessSectionHeader(title: 'Advertisements'),
            MyBusinessAdsSectionObx(
              ads: profileController.myAds,
              isLoading: profileController.isLoadingAds,
              creditsRemaining: creditsRemaining,
            ),
            const SizedBox(height: 12),
            CustomButton(
              backgroundColor: colorScheme.primary,
              onPressed: onCreateAdTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: colorScheme.onPrimary, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Create New Ads',
                    style: AppTextStyle.textSm(
                      weight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            MyBusinessSectionHeader(
              title: 'Reviews',
              showViewAll: true,
              onViewAllTap: onViewAllReviewsTap,
            ),
            const MyBusinessReviewsPreview(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
