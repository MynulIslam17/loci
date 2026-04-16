import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/busniess/update_business_request_model.dart';
import 'package:loci/presentation/controllers/my_business/my_business_profile_controller.dart';
import 'package:loci/presentation/controllers/profile/profile_controller.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/pages/clam_business/widgets/review_card.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/routes/app_routes.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../data/models/busniess/business_profile_model.dart';
import '../../widgets/app_bottom_seet.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_image_container.dart';
import '../../widgets/image_picker_helper.dart';
import '../home/widgets/post_input_filed.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class MyBusinessProfile extends StatefulWidget {
  const MyBusinessProfile({super.key});

  @override
  State<MyBusinessProfile> createState() => _MyBusinessProfileState();
}

class _MyBusinessProfileState extends State<MyBusinessProfile> {
  //-----states------
  File? _profileImage;
  final List<File> _photos = [];

  late final String businessId;

  final profileController = Get.find<MyBusinessProfileController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final args = Get.arguments;
    businessId = (args is Map && args['businessId'] != null)
        ? args['businessId']
        : '';

    profileController.fetchBusinessProfile(businessId);
  }

  //----- method to upload business logo
  Future<void> _uploadLogo(File file) async {
    final success = await profileController.uploadBusinessImages(
      businessId: businessId,
      logo: file,
    );

    if (success) {
      SnackbarService.success("Logo updated successfully");
    } else {
      SnackbarService.error(profileController.errorMessage!);
    }
  }

  //----- method to upload business phots
  Future<void> _uploadPhotos(List<File> files) async {
    if (files.isEmpty) return;

    final success = await profileController.uploadBusinessImages(
      businessId: businessId,
      photos: files,
    );

    if (success) {
      _photos.clear();
      SnackbarService.success("Photos updated successfully");
    } else {
      SnackbarService.error(profileController.errorMessage!);
    }
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
        profileController.errorMessage ?? "Failed to remove photo",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: "Business profile"),
      body: GetBuilder<MyBusinessProfileController>(
        builder: (controller) {
          //===== FULL PAGE LOADING STATE

          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          //===== EMPTY / ERROR STATE

          if (controller.business == null) {
            return const Center(child: Text("No business found"));
          }

          //==== MAIN UI + LOADING OVERLAY

          return Stack(
            children: [
              //==== MAIN PAGE CONTENT
              _buildBody(context, controller, controller.business!),

              // =====Edit overlay loader
              if (controller.isUpdating)
                Container(
                  color: Colors.black.withOpacity(0.15), //dim the background
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  ///----- main body widget
  Widget _buildBody(
    BuildContext context,
    MyBusinessProfileController controller,
    BusinessModel business,
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

            // ================= POLL / AD CREATOR =================
            _buildSectionHeader("Advertisements"),
            _buildPollCreator(),

            const SizedBox(height: 12),

            CustomButton(
              text: "Explore Activities",
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Get.toNamed(
                  AppRoutes.exploreActivity,
                  arguments: {"businessId": businessId},
                );
              },
              textStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
            ),

            const SizedBox(height: 25),

            // ================= HERO ADS =================
            _buildSectionHeader("Hero Ads"),

            _buildHeroAd(),

            const SizedBox(height: 12),

            CustomButton(
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Get.toNamed(AppRoutes.createAdd);
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
            _buildSectionHeader("Reviews", showViewAll: true, onTap: () {}),

            _buildReviewsList(),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================
  Widget _buildProfileHeader(BusinessModel business) {
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
              child: CustomCachedImage(
                imageFile: _profileImage,
                imageUrl: business.logo,
                height: 110,
                width: 110,
                isCircle: true,
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
                    setState(() {
                      _profileImage = file.isNotEmpty ? file.first : null;
                    });

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
              onTap: () {},
              backgroundColor: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            customChip(
              label: "QR",
              icon: Icons.qr_code,
              onTap: () {},
              backgroundColor: colorScheme.primary,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ================= BUTTON =================
        OutlinedButton(
          onPressed: () {},
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
  Widget _buildDescriptionCard(BuildContext context, BusinessModel business) {
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
  Widget _buildPhotoGrid(BusinessModel business) {
    final _apiPhotos = business.photos;
    final int totalImages = _apiPhotos.length + _photos.length;

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

        if (index < _apiPhotos.length) {
          return Stack(
            children: [
              CustomCachedImage(
                imageUrl: _apiPhotos[index],
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                right: 5,
                top: 5,
                child: _editCircleButton(
                  onTap: () {
                    setState(() => _removeApiPhoto(_apiPhotos[index]));
                  },
                  size: 20,
                  icon: Icons.cancel,
                  iconColor: AppColors.danger,
                ),
              ),
            ],
          );
        }

        final localIndex = index - _apiPhotos.length;
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
                  setState(() => _photos.removeAt(localIndex));
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

  // ================= POLL CREATOR =================
  Widget _buildPollCreator() {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create a poll",
              style: AppTextStyle.textMd(
                color: colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            PostInputField(
              categories: ['Foodie', 'Drinks', 'Restu'],
              initialCategory: 'Foodie',
              hintText: 'Ask anything',
              onSubmit: (text, category) {
                print("Posting: $text in $category");
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= REVIEWS LIST =================
  Widget _buildReviewsList() {
    return Column(
      children: List.generate(
        2,
        (index) => ReviewCard(
          name: "Alexandra ssssBroke",
          businessName: "Barclay Pizza",
          rating: 5,
          reviewText: "This was one of the most epic experience...",
          imageUrl: "https://i.pravatar.cc/150?u=1",
          onMenuTap: () {},
        ),
      ),
    );
  }

  // ================= BUTTON TO PICK MULTIPLE PHOTO =================
  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: () => showImagePickerSheet(
        context: context,
        allowMultiple: true,
        onPicked: (files) {
          if (files.isEmpty) return;

          setState(() {
            _photos.addAll(files);
          });
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

  void _showEditBusinessBottomSheet(BusinessModel business) {
    final colorScheme = context.colorScheme;
    final formKey = GlobalKey<FormState>();

    final nameTEController = TextEditingController(text: business.name);
    final locationTEController = TextEditingController(text: business.location);

    BusinessCategory selectedCategory = BusinessCategory.fromString(
      business.category,
    );

    String phoneNumber = business.phone;

    AppBottomSheet.show(
      title: "Edit Business Info",
      formKey: formKey,
      child: Column(
        children: [
          // ================= NAME =================
          CustomTextField(
            controller: nameTEController,
            borderColor: colorScheme.outline,
            validator: (value) => value == null || value.trim().isEmpty
                ? "Name is required"
                : null,
          ),

          const SizedBox(height: 12),

          // ================= PHONE =================
          IntlPhoneField(
            initialValue: business.phone,
            initialCountryCode: 'US',
            decoration: InputDecoration(
              labelText: "Phone Number",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (phone) {
              phoneNumber = phone.completeNumber;
            },
            validator: (phone) => phone == null || phone.number.isEmpty
                ? "Phone is required"
                : null,
          ),

          const SizedBox(height: 12),

          // ================= LOCATION =================
          CustomTextField(
            controller: locationTEController,
            borderColor: colorScheme.outline,
            validator: (value) => value == null || value.trim().isEmpty
                ? "Location required"
                : null,
          ),

          const SizedBox(height: 12),

          // ================= CATEGORY =================
          CustomDropdown<BusinessCategory>(
            value: selectedCategory,
            onChanged: (BusinessCategory? value) {
              if (value == null) return;
              setState(() {
                selectedCategory = value;
              });
            },
            items: BusinessCategory.values.map((category) {
              return DropdownMenuItem<BusinessCategory>(
                value: category,
                child: Text(category.label),
              );
            }).toList(),
          ),
        ],
      ),

      onSubmit: () async {
        final requestData = UpdateBusinessRequest(
          name: nameTEController.text.trim(),
          location: locationTEController.text.trim(),
          phone: phoneNumber.trim(),
          category: selectedCategory.toJson,
        );

        await profileController.updateBusinessText(
          businessId: businessId,
          body: requestData.toJson(),
        );
      },
    );
  }

  void _showEditDescriptionBottomSheet(BusinessModel business) {
    final colorScheme = context.colorScheme;
    final formKey = GlobalKey<FormState>();
    final descriptionTEController = TextEditingController(
      text: business.description,
    );

    AppBottomSheet.show(
      title: "Edit Description",
      formKey: formKey,
      child: CustomTextField(
        controller: descriptionTEController,
        hintText: "Enter Description",
        maxLine: 3,
        borderColor: colorScheme.outline,
        validator: (value) =>
            value == null || value.isEmpty ? "Required" : null,
      ),
      onSubmit: () async {
        final requestData = UpdateBusinessRequest(
          description: descriptionTEController.text.trim(),
        );
        await profileController.updateBusinessText(
          businessId: businessId,
          body: requestData.toJson(),
        );
      },
    );
  }
}
