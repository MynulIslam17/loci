import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/community/presentation/controllers/community_qr_controller.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
import 'package:loci/features/my_business/presentation/controllers/business_review_controller.dart';
import 'package:loci/features/my_business/presentation/controllers/my_business_profile_controller.dart';
import 'package:loci/features/my_business/presentation/widgets/edit_business_info_form.dart';
import 'package:loci/features/my_business/presentation/widgets/edit_circle_button.dart';
import 'package:loci/features/my_business/presentation/widgets/edit_description_form.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_profile_shimmer.dart';
import 'package:loci/features/my_business/presentation/widgets/profile_bottom_sheet.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/image_picker_helper.dart';
import 'package:loci/shared/widgets/qrcode_maker.dart';
import 'package:loci/shared/widgets/review_card.dart';

class MyBusinessProfile extends StatefulWidget {
  const MyBusinessProfile({super.key});

  @override
  State<MyBusinessProfile> createState() => _MyBusinessProfileState();
}

class _MyBusinessProfileState extends State<MyBusinessProfile> {
  final _profileImage = Rxn<File>();
  final _photos = <File>[].obs;

  late final String businessId;

  final profileController = Get.find<MyBusinessProfileController>();
  final reviewController = Get.find<MyBusinessReviewController>();
  final _communityQrController = Get.find<CommunityQrController>();

  bool _didMutateProfile = false;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    businessId = (args is Map && args['businessId'] != null)
        ? args['businessId'] as String
        : '';

    profileController.fetchBusinessProfile(businessId).then((_) {
      if (!mounted) return;
      final communityId = profileController.business.value?.community.id ?? '';
      if (communityId.isNotEmpty) {
        _communityQrController.fetchQr(communityId);
      }
    });
    reviewController.fetchReviews(businessId);
  }

  @override
  void dispose() {
    Get.delete<MyBusinessReviewController>();
    super.dispose();
  }

  Future<void> _uploadLogo(File file) async {
    final success = await profileController.uploadBusinessImages(
      businessId: businessId,
      logo: file,
    );

    if (!mounted) return;

    _profileImage.value = null;
    if (success) {
      _didMutateProfile = true;
    } else {
      SnackbarService.error(profileController.errorMessage.value!);
    }
  }

  Future<void> _uploadPhotos(List<File> files) async {
    if (files.isEmpty) return;

    final success = await profileController.uploadBusinessImages(
      businessId: businessId,
      photos: files,
    );

    if (!mounted) return;

    if (success) {
      _didMutateProfile = true;
      _photos.clear();
    } else {
      _photos.removeWhere(files.contains);
      SnackbarService.error(profileController.errorMessage.value!);
    }
  }

  Future<void> _showCommunityQr(BusinessProfileModel business) async {
    final community = business.community;
    if (community.id.isEmpty) {
      SnackbarService.error('No community linked to this business');
      return;
    }

    var qr = _communityQrController.cachedQr(community.id);

    if (qr == null) {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      qr = await _communityQrController.fetchQr(community.id);

      if (Get.isDialogOpen ?? false) Get.back();
      if (!mounted) return;
    }

    if (qr == null) {
      SnackbarService.error(
        _communityQrController.errorMessage.value ?? 'Failed to load QR code',
      );
      return;
    }

    final communityName = community.name.isNotEmpty
        ? community.name
        : 'this community';

    CustomQrCode.show(
      context,
      data: qr,
      title: community.name.isNotEmpty ? community.name : 'Community QR',
      subtitle: 'Scan this QR code to join $communityName',
    );
  }

  Future<void> _removeApiPhoto(String photoUrl) async {
    final success = await profileController.removeBusinessPhoto(
      businessId: businessId,
      photoUrl: photoUrl,
    );

    if (success) {
      _didMutateProfile = true;
    } else {
      SnackbarService.error(
        profileController.errorMessage.value ?? 'Failed to remove photo',
      );
    }
  }

  void _popWithRefreshHint() {
    if (_didMutateProfile) {
      final snapshot = profileController.business.value;
      Get.back(
        result: snapshot != null
            ? {'updated': true, 'profile': snapshot}
            : const {'updated': true},
      );
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popWithRefreshHint();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: const CustomAppbar(title: 'Business profile'),
        body: Obx(() {
          if (profileController.isLoading.value) {
            return const MyBusinessProfileShimmer();
          }

          final business = profileController.business.value;
          if (business == null) {
            return const Center(child: Text('No business found'));
          }

          return Stack(
            children: [
              _buildBody(context, business),
              if (profileController.isUpdating.value)
                Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BusinessProfileModel business) {
    final colorScheme = context.colorScheme;

    return RefreshIndicator(
      onRefresh: () => profileController.silentRefresh(businessId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildProfileHeader(business),
            const SizedBox(height: 20),
            _buildDescriptionCard(business),
            const SizedBox(height: 25),
            _buildSectionHeader('Photos'),
            _buildPhotoGrid(business),
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
            _buildSectionHeader('Advertisements'),
            _buildHeroAd(),
            const SizedBox(height: 12),
            CustomButton(
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Get.toNamed(
                  AppRoutes.createAdd,
                  arguments: {'businessName': business.name},
                );
              },
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
            _buildSectionHeader(
              'Reviews',
              showViewAll: true,
              onTap: () {
                Get.toNamed(
                  AppRoutes.myBusinessAllReviews,
                  arguments: {
                    'businessId': businessId,
                    'reviewCount': business.reviewCount,
                    'rating': business.rating,
                  },
                );
              },
            ),
            _buildReviewsList(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BusinessProfileModel business) {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary),
              ),
              child: Obx(
                () => CustomCachedImage(
                  imageFile: _profileImage.value,
                  imageUrl: business.logo,
                  height: 110,
                  width: 110,
                  isCircle: true,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: EditCircleButton(
                onTap: () => showImagePickerSheet(
                  context: context,
                  allowMultiple: false,
                  onPicked: (file) {
                    if (file.isEmpty) return;
                    _profileImage.value = file.first;
                    _uploadLogo(file.first);
                  },
                ),
              ),
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
                child: EditCircleButton(
                  onTap: () => _showEditBusinessBottomSheet(business),
                ),
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
            _actionChip(
              label: 'Community',
              onTap: () => Get.toNamed(AppRoutes.allCommunity),
              backgroundColor: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            _actionChip(
              label: 'QR',
              icon: Icons.qr_code,
              onTap: () => _showCommunityQr(business),
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

  Widget _buildDescriptionCard(BusinessProfileModel business) {
    final colorScheme = context.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: colorScheme.surfaceContainerHigh,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: EditCircleButton(
                  onTap: () => _showEditDescriptionBottomSheet(business),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  business.description,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(BusinessProfileModel business) {
    final apiPhotos = business.photos;

    return Obx(() {
      final totalImages = apiPhotos.length + _photos.length;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: totalImages + 1,
        itemBuilder: (context, index) {
          if (index == totalImages) return _buildAddPhotoButton();

          if (index < apiPhotos.length) {
            return Stack(
              children: [
                CustomCachedImage(
                  imageUrl: apiPhotos[index],
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: EditCircleButton(
                    onTap: () => _removeApiPhoto(apiPhotos[index]),
                    size: 20,
                    icon: Icons.cancel,
                    iconColor: AppColors.danger,
                  ),
                ),
              ],
            );
          }

          final localIndex = index - apiPhotos.length;
          return Stack(
            children: [
              CustomCachedImage(
                imageFile: _photos[localIndex],
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                right: 5,
                top: 5,
                child: EditCircleButton(
                  onTap: () => _photos.removeAt(localIndex),
                  size: 20,
                  icon: Icons.cancel,
                  iconColor: AppColors.danger,
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildHeroAd() {
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Stack(
            children: [
              CustomCachedImage(
                width: double.infinity,
                height: 200,
                imageUrl: 'https://picsum.photos/seed/1/400/300',
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Barclay Prime',
                      style: AppTextStyle.textMd(
                        color: AppColors.base50,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '237 S 18th St, Philadelphia, PA 19103',
                            style: AppTextStyle.textXs(
                              color: AppColors.base50,
                              weight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ads will run February 2, 2026',
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                    weight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Credit remain: 10',
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                    weight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return Obx(() {
      if (reviewController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (reviewController.reviews.isEmpty) {
        return const EmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No reviews yet',
          subtitle: 'Be the first to leave a review!',
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

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: () => showImagePickerSheet(
        context: context,
        allowMultiple: true,
        onPicked: (files) {
          if (files.isEmpty) return;
          _photos.addAll(files);
          _uploadPhotos(files);
        },
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_outlined, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Add image',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.transparent),
      ),
      avatar: icon != null ? Icon(icon, size: 18, color: Colors.white) : null,
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    bool showViewAll = false,
    VoidCallback? onTap,
  }) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyle.textXl(
              color: colorScheme.primary,
              weight: FontWeight.w600,
            ),
          ),
          if (showViewAll)
            TextButton(
              onPressed: onTap,
              child: Text(
                'View all',
                style: AppTextStyle.textXs(color: colorScheme.primary),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditBusinessBottomSheet(BusinessProfileModel business) {
    ProfileBottomSheet.show(
      title: 'Edit Business Info',
      child: EditBusinessInfoForm(
        business: business,
        onSubmit: (body) async {
          final success = await profileController.updateBusinessText(
            businessId: businessId,
            body: body,
          );
          if (success) _didMutateProfile = true;
          return success;
        },
      ),
    );
  }

  void _showEditDescriptionBottomSheet(BusinessProfileModel business) {
    ProfileBottomSheet.show(
      title: 'Edit Description',
      child: EditDescriptionForm(
        initialValue: business.description,
        onSubmit: (body) async {
          final success = await profileController.updateBusinessText(
            businessId: businessId,
            body: body,
          );
          if (success) _didMutateProfile = true;
          return success;
        },
      ),
    );
  }
}
