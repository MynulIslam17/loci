import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/controllers/community_qr_controller.dart';
import 'package:loci/features/my_business/data/models/update_business_request_model.dart';
import 'package:loci/features/my_business/presentation/controllers/business_review_controller.dart';
import 'package:loci/features/my_business/presentation/widgets/my_business_profile_shimmer.dart';
import 'package:loci/features/my_business/presentation/controllers/my_business_profile_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/review_card.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import '../widgets/profile_bottom_sheet.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/image_picker_helper.dart';
import 'package:loci/shared/widgets/qrcode_maker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/countries.dart';

class MyBusinessProfile extends StatefulWidget {
  const MyBusinessProfile({super.key});

  @override
  State<MyBusinessProfile> createState() => _MyBusinessProfileState();
}

class _MyBusinessProfileState extends State<MyBusinessProfile> {
  //-----states------
  final _profileImage = Rxn<File>();
  final _photos = <File>[].obs;

  late final String businessId;

  final profileController = Get.find<MyBusinessProfileController>();
  final reviewController = Get.find<MyBusinessReviewController>();
  final _communityQrController = Get.find<CommunityQrController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final args = Get.arguments;
    businessId = (args is Map && args['businessId'] != null)
        ? args['businessId']
        : '';

    // Warm the community QR cache once the profile (and its community id)
    // is available, so tapping the QR chip later shows no loader.
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

  //----- method to upload business logo
  Future<void> _uploadLogo(File file) async {
    final success = await profileController.uploadBusinessImages(
      businessId: businessId,
      logo: file,
    );

    if (!mounted) return;

    if (success) {
      // Drop the local preview now that the server URL has refreshed.
      _profileImage.value = null;
    } else {
      _profileImage.value = null;
      SnackbarService.error(profileController.errorMessage.value!);
    }
  }

  //----- method to upload business phots
  Future<void> _uploadPhotos(List<File> files) async {
    if (files.isEmpty) return;

    final success = await profileController.uploadBusinessImages(
      businessId: businessId,
      photos: files,
    );

    if (!mounted) return;

    if (success) {
      _photos.clear();
    } else {
      _photos.removeWhere(files.contains);
      SnackbarService.error(profileController.errorMessage.value!);
    }
  }

  //----- fetch the community's signed QR token and show it in a sheet
  Future<void> _showCommunityQr(BusinessProfileModel business) async {
    final community = business.community;
    if (community.id.isEmpty) {
      SnackbarService.error("No community linked to this business");
      return;
    }

    // Serve instantly if this community's token was already fetched; only
    // show the loader + hit the network on a cache miss.
    var qr = _communityQrController.cachedQr(community.id);

    if (qr == null) {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      qr = await _communityQrController.fetchQr(community.id);

      if (Get.isDialogOpen ?? false) Get.back(); // dismiss loader
      if (!mounted) return;
    }

    if (qr == null) {
      SnackbarService.error(
        _communityQrController.errorMessage.value ?? "Failed to load QR code",
      );
      return;
    }

    final communityName = community.name.isNotEmpty
        ? community.name
        : "this community";

    CustomQrCode.show(
      context,
      data: qr,
      title: community.name.isNotEmpty ? community.name : "Community QR",
      subtitle: "Scan this QR code to join $communityName",
    );
  }

  //----- method to remove business phots
  Future<void> _removeApiPhoto(String photoUrl) async {
    final success = await profileController.removeBusinessPhoto(
      businessId: businessId,
      photoUrl: photoUrl,
    );

    if (success) {
      // SnackbarService.success("Photo removed");
    } else {
      SnackbarService.error(
        profileController.errorMessage.value ?? "Failed to remove photo",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: "Business profile"),
      body: Obx(() {
        final controller = Get.find<MyBusinessProfileController>();
        //===== FULL PAGE LOADING STATE

        if (controller.isLoading.value) {
          return const MyBusinessProfileShimmer();
        }

        //===== EMPTY / ERROR STATE

        if (controller.business.value == null) {
          return const Center(child: Text("No business found"));
        }

        //==== MAIN UI + LOADING OVERLAY

        return Stack(
          children: [
            //==== MAIN PAGE CONTENT
            _buildBody(context, controller, controller.business.value!),

            // =====Edit overlay loader
            if (controller.isUpdating.value)
              Container(
                color: Colors.black.withValues(alpha: 0.15),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  ///----- main body widget
  Widget _buildBody(
    BuildContext context,
    MyBusinessProfileController controller,
    BusinessProfileModel business,
  ) {
    final colorScheme = context.colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.silentRefresh(businessId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // ================= PROFILE HEADER =================
            _buildProfileHeader(business),

            const SizedBox(height: 20),

            // ================= DESCRIPTION =================
            _buildDescriptionCard(context, business),

            const SizedBox(height: 25),

            // ================= PHOTOS =================
            _buildSectionHeader("Photos"),
            _buildPhotoGrid(business),

            const SizedBox(height: 20),

            // ================= EXPLORE ACTIVITIES =================
            CustomButton(
              text: "Explore Activities",
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Get.toNamed(
                  AppRoutes.exploreActivity,
                  arguments: {
                    "businessName": business.name,
                    "businessId": business.id,
                  },
                );
              },
              textStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
            ),

            const SizedBox(height: 25),

            // ================= ADVERTISEMENTS =================
            _buildSectionHeader("Advertisements"),

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
                    "Create New Ads",
                    style: AppTextStyle.textSm(
                      weight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= REVIEWS =================
            _buildSectionHeader(
              "Reviews",
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

  // ================= PROFILE HEADER =================
  Widget _buildProfileHeader(BusinessProfileModel business) {
    final colorScheme = context.colorScheme;

    final location = business.location;

    return Column(
      children: [
        const SizedBox(height: 10),

        // ================= PROFILE IMAGE =================
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
              child: _editCircleButton(
                onTap: () => showImagePickerSheet(
                  context: context,
                  allowMultiple: false,

                  onPicked: (file) {
                    _profileImage.value = file.isNotEmpty ? file.first : null;

                    _uploadLogo(file.first);
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // ================= BUSINESS INFO CARD =================
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
                    // NAME
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

                    // ADDRESS
                    Text(
                      location,
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

              // EDIT BUTTON ================
              Positioned(
                top: 0,
                right: 0,
                child: _editCircleButton(
                  onTap: () => _showEditBusinessBottomSheet(business),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ================= REVIEW SECTION (FIXED) =================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${business.reviewCount} reviews",
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 6),

            //review count
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

        // ================= CHIPS =================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customChip(
              label: "Community",
              onTap: () => Get.toNamed(AppRoutes.allCommunity),
              backgroundColor: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            customChip(
              label: "QR",
              icon: Icons.qr_code,
              onTap: () => _showCommunityQr(business),
              backgroundColor: colorScheme.primary,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ================= BUTTON =================
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
            "Change Subscription",
            style: AppTextStyle.textSm(
              color: colorScheme.primary,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ================= DESCRIPTION CARD =================
  Widget _buildDescriptionCard(
    BuildContext context,
    BusinessProfileModel business,
  ) {
    final colorScheme = context.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: colorScheme.surfaceContainerHigh,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // TEXT CONTENT
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  business.description,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // EDIT BUTTON
              Positioned(
                right: 0,
                top: 0,
                child: _editCircleButton(
                  onTap: () => _showEditDescriptionBottomSheet(business),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PHOTO GRID =================
  Widget _buildPhotoGrid(BusinessProfileModel business) {
    final apiPhotos = business.photos;

    return Obx(() {
      final int totalImages = apiPhotos.length + _photos.length;

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
                  child: _editCircleButton(
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
                child: _editCircleButton(
                  onTap: () {
                    _photos.removeAt(localIndex);
                  },
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

  // ================= HERO AD =================
  Widget _buildHeroAd() {
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Stack(
            children: [
              // Background Image
              CustomCachedImage(
                width: double.infinity,
                height: 200,
                imageUrl: "https://picsum.photos/seed/1/400/300",
              ),

              // Text Content
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Barclay Prime",
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
                            "237 S 18th St, Philadelphia, PA 19103",
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
          // Ads Info
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ads will run February 2, 2026",
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                    weight: FontWeight.w400,
                  ),
                ),
                Text(
                  "Credit remain: 10",
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

  // ================= REVIEWS LIST =================

  Widget _buildReviewsList() {
    return Obx(() {
      final controller = Get.find<MyBusinessReviewController>();
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.reviews.isEmpty) {
        return const EmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No reviews yet',
          subtitle: 'Be the first to leave a review!',
        );
      }

      return Column(
        children: controller.reviews.take(2).map((review) {
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

  // ================= BUTTON TO PICK MULTIPLE PHOTO =================
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
              "Add image",
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

  // ================= CUSTOM CHIP =================
  Widget customChip({
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

  // ================= SECTION HEADER =================
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
                "View all",
                style: AppTextStyle.textXs(color: colorScheme.primary),
              ),
            ),
        ],
      ),
    );
  }

  // ================= EDIT CIRCLE BUTTON =================
  Widget _editCircleButton({
    required VoidCallback onTap,
    double size = 26,
    IconData icon = Icons.edit_outlined,
    Color iconColor = AppColors.primaryG700,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: size * 0.7, color: iconColor),
        ),
      ),
    );
  }

  // ================= EDIT BUSINESS INFO BOTTOM SHEET =================

  void _showEditBusinessBottomSheet(BusinessProfileModel business) {
    ProfileBottomSheet.show(
      title: "Edit Business Info",
      child: _EditBusinessInfoForm(
        business: business,
        onSubmit: (body) => profileController.updateBusinessText(
          businessId: businessId,
          body: body,
        ),
      ),
    );
  }

  void _showEditDescriptionBottomSheet(BusinessProfileModel business) {
    ProfileBottomSheet.show(
      title: "Edit Description",
      child: _EditDescriptionForm(
        initialValue: business.description,
        onSubmit: (description) => profileController.updateBusinessText(
          businessId: businessId,
          body: UpdateBusinessRequest(description: description).toJson(),
        ),
      ),
    );
  }
}

/// Splits a stored phone (e.g. "+8801712345678") into the matching ISO
/// country code and local-number portion expected by IntlPhoneField.
/// Falls back to US + raw value when the prefix can't be matched.
({String code, String number}) _splitPhone(String raw) {
  final trimmed = raw.trim();
  if (!trimmed.startsWith('+')) {
    return (code: 'US', number: trimmed);
  }
  final digits = trimmed.substring(1);
  // Sort longest-first so e.g. +1242 (Bahamas) matches before +1 (US).
  final sorted = [...countries]
    ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
  for (final c in sorted) {
    if (digits.startsWith(c.dialCode)) {
      return (code: c.code, number: digits.substring(c.dialCode.length));
    }
  }
  return (code: 'US', number: trimmed);
}

// ================= EDIT BUSINESS INFO FORM =================
class _EditBusinessInfoForm extends StatefulWidget {
  final BusinessProfileModel business;
  final Future<bool> Function(Map<String, dynamic> body) onSubmit;

  const _EditBusinessInfoForm({required this.business, required this.onSubmit});

  @override
  State<_EditBusinessInfoForm> createState() => _EditBusinessInfoFormState();
}

class _EditBusinessInfoFormState extends State<_EditBusinessInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final Rx<BusinessCategory> _category;
  late String _phone;
  late final ({String code, String number}) _parsedPhone;
  final _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business.name);
    _locationController = TextEditingController(text: widget.business.location);
    _category = Rx(BusinessCategory.fromString(widget.business.category));
    _phone = widget.business.phone;
    _parsedPhone = _splitPhone(widget.business.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _isSubmitting.value = true;
    try {
      final body = UpdateBusinessRequest(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        phone: _phone.trim(),
        category: _category.value.toJson,
      ).toJson();
      await widget.onSubmit(body);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _nameController,
            borderColor: colorScheme.outline,
            validator: (value) => value == null || value.trim().isEmpty
                ? "Name is required"
                : null,
          ),
          const SizedBox(height: 12),
          IntlPhoneField(
            initialValue: _parsedPhone.number,
            initialCountryCode: _parsedPhone.code,
            decoration: InputDecoration(
              labelText: "Phone Number",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (phone) => _phone = phone.completeNumber,
            validator: (phone) => phone == null || phone.number.isEmpty
                ? "Phone is required"
                : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _locationController,
            borderColor: colorScheme.outline,
            validator: (value) => value == null || value.trim().isEmpty
                ? "Location required"
                : null,
          ),
          const SizedBox(height: 12),
          Obx(
            () => CustomDropdown<BusinessCategory>(
              value: _category.value,
              onChanged: (value) {
                if (value == null) return;
                _category.value = value;
              },
              items: BusinessCategory.values
                  .map(
                    (category) => DropdownMenuItem<BusinessCategory>(
                      value: category,
                      child: Text(category.label),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => CustomButton(
              isLoading: _isSubmitting.value,
              text: "Update",
              onPressed: _isSubmitting.value ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= EDIT DESCRIPTION FORM =================
class _EditDescriptionForm extends StatefulWidget {
  final String initialValue;
  final Future<bool> Function(String description) onSubmit;

  const _EditDescriptionForm({
    required this.initialValue,
    required this.onSubmit,
  });

  @override
  State<_EditDescriptionForm> createState() => _EditDescriptionFormState();
}

class _EditDescriptionFormState extends State<_EditDescriptionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  final _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _isSubmitting.value = true;
    try {
      await widget.onSubmit(_controller.text.trim());
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _controller,
            hintText: "Enter Description",
            maxLine: 3,
            borderColor: colorScheme.outline,
            validator: (value) =>
                value == null || value.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 20),
          Obx(
            () => CustomButton(
              isLoading: _isSubmitting.value,
              text: "Update",
              onPressed: _isSubmitting.value ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}
