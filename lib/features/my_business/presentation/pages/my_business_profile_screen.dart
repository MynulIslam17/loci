import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/community/presentation/controllers/community_qr_controller.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
import 'package:loci/features/my_business/presentation/controllers/business_review_controller.dart';
import 'package:loci/features/my_business/presentation/controllers/my_business_profile_controller.dart';
import 'package:loci/features/my_business/presentation/widgets/edit_business_info_form.dart';
import 'package:loci/features/my_business/presentation/widgets/edit_description_form.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_profile_body.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_profile_shimmer.dart';
import 'package:loci/features/my_business/presentation/widgets/profile_bottom_sheet.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/image_picker_helper.dart';
import 'package:loci/shared/widgets/qrcode_maker.dart';

class MyBusinessProfile extends StatefulWidget {
  const MyBusinessProfile({super.key});

  @override
  State<MyBusinessProfile> createState() => _MyBusinessProfileState();
}

class _MyBusinessProfileState extends State<MyBusinessProfile> {
  final _profileImage = Rxn<File>();
  final _photos = <File>[].obs;
  final _creditsRemaining = RxnInt();

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
    profileController.fetchMyAds(businessId: businessId);
    _loadSpotlightCredits();
  }

  Future<void> _loadSpotlightCredits() async {
    try {
      final sub = await Get.find<SubscriptionService>().getMySubscription(
        businessId,
      );
      if (!mounted) return;
      _creditsRemaining.value =
          sub?.credits?.remaining ?? sub?.heroSpotlightCredits;
    } catch (_) {}
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

  Future<void> _openCreateAd(BusinessProfileModel business) async {
    final created = await Get.toNamed(
      AppRoutes.createAdd,
      arguments: {
        'businessId': business.id,
        'businessName': business.name,
        'location': business.location,
      },
    );
    if (created == true) {
      await profileController.fetchMyAds(businessId: businessId);
      await _loadSpotlightCredits();
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
              MyBusinessProfileBody(
                business: business,
                profileImage: _profileImage,
                localPhotos: _photos,
                creditsRemaining: _creditsRemaining,
                onRefresh: () => profileController.silentRefresh(businessId),
                onEditBusinessTap: () => _showEditBusinessBottomSheet(business),
                onEditDescriptionTap: () =>
                    _showEditDescriptionBottomSheet(business),
                onLogoPick: () => showImagePickerSheet(
                  context: context,
                  allowMultiple: false,
                  onPicked: (file) {
                    if (file.isEmpty) return;
                    _profileImage.value = file.first;
                    _uploadLogo(file.first);
                  },
                ),
                onCommunityQrTap: () => _showCommunityQr(business),
                onAddPhotos: (files) {
                  _photos.addAll(files);
                  _uploadPhotos(files);
                },
                onRemoveLocalPhoto: (index) => _photos.removeAt(index),
                onRemoveApiPhoto: _removeApiPhoto,
                onCreateAdTap: () => _openCreateAd(business),
                onViewAllReviewsTap: () {
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
