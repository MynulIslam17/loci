import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/enums/community_role.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
import 'package:loci/features/my_business/presentation/widgets/edit_circle_button.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_action_chip.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/image_viewer.dart';

class MyBusinessProfileHeader extends StatelessWidget {
  const MyBusinessProfileHeader({
    super.key,
    required this.business,
    required this.profileImage,
    required this.onEditBusinessTap,
    required this.onLogoPick,
    required this.onCommunityQrTap,
  });

  final BusinessProfileModel business;
  final Rxn<File> profileImage;
  final VoidCallback onEditBusinessTap;
  final VoidCallback onLogoPick;
  final VoidCallback onCommunityQrTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                final file = profileImage.value;
                showImageViewer(
                  context,
                  imageFile: file,
                  imageUrl: business.logo,
                  heroTag: 'business-logo-${business.id}',
                );
              },
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary),
                ),
                child: Obx(
                  () => Hero(
                    tag: 'business-logo-${business.id}',
                    child: CustomCachedImage(
                      imageFile: profileImage.value,
                      imageUrl: business.logo,
                      height: 110,
                      width: 110,
                      isCircle: true,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: EditCircleButton(onTap: onLogoPick),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      business.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.textXl(
                        color: colorScheme.primary,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      business.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      business.phone,
                      style: AppTextStyle.textXs(
                        color: colorScheme.primary,
                        weight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      business.category,
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: EditCircleButton(onTap: onEditBusinessTap),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${business.reviewCount} reviews',
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 6),
            Row(
              children: List.generate(
                5,
                (index) => const Icon(
                  Icons.star,
                  color: AppColors.starColor,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyBusinessActionChip(
              label: 'Community',
              onTap: () {
                final community = business.community;
                if (community.id.isEmpty) {
                  SnackbarService.error('No community linked to this business');
                  return;
                }
                Get.toNamed(
                  AppRoutes.communityScreen,
                  arguments: {
                    'communityRole': CommunityRole.owner,
                    'communityId': community.id,
                    'communityName': community.name,
                  },
                );
              },
              backgroundColor: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            MyBusinessActionChip(
              label: 'QR',
              icon: Icons.qr_code,
              onTap: onCommunityQrTap,
              backgroundColor: colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Get.toNamed(AppRoutes.subscription),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40),
          ),
          child: Text(
            'Change Subscription',
            style: AppTextStyle.textSm(
              color: colorScheme.primary,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
