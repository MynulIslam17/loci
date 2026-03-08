import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/pages/clam_business/widgets/review_card.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_image_container.dart';
import '../../widgets/custom_imagepicker.dart';
import '../home/widgets/post_input_filed.dart';


class MyBusinessProfile extends StatefulWidget {
  const MyBusinessProfile({super.key});

  @override
  State<MyBusinessProfile> createState() => _MyBusinessProfileState();
}

class _MyBusinessProfileState extends State<MyBusinessProfile> {
  File? _profileImage;
  final List<File> _photos = [];
  final Color primaryTeal = const Color(0xFF64BDB1);

  final List<String> _apiPhotos = [
    "https://picsum.photos/seed/1/400/300",
    "https://picsum.photos/seed/2/400/300",
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title:  "Business profile",),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildDescriptionCard(context),
            const SizedBox(height: 25),
            _buildSectionHeader("Photos"),
            _buildPhotoGrid(),
            const SizedBox(height: 25),
            _buildSectionHeader("Advertisements"),
            _buildPollCreator(),
            const SizedBox(height: 12),
            CustomButton(
              text: "Explore Activities",
              backgroundColor: colorScheme.primary,
              onPressed: () {
                //--go to explore activity
                Get.toNamed(AppRoutes.exploreActivity);

              },
              textStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 25),
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
            _buildSectionHeader("Reviews", showViewAll: true, onTap: () {}),
            _buildReviewsList(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================
  Widget _buildProfileHeader() {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          children: [
            // Profile Image
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary),
              ),
              child: CustomCachedImage(
                imageFile: _profileImage,
                imageUrl: "https://via.placeholder.com/150",
                height: 110,
                width: 110,
                isCircle: true,
              ),
            ),
            // Edit Profile Button
            Positioned(
              right: 0,
              top: 0,
              child: _editCircleButton(() {
                CustomImagePicker.pickImageSimple(
                  context: context,
                  onImageSelected: (file) => setState(() {
                    _profileImage = file;
                  }),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Business Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            children: [
              Column(
                children: [
                  Text(
                    "Marland Clutch",
                    style: AppTextStyle.textXl(
                      color: colorScheme.primary,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "23601 Hoover Rd, Warren, MI 48089",
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "+1 800-216-3515",
                    style: AppTextStyle.textXs(color: colorScheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Maintenance & Repair | Services & More",
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Edit Button for Business Info
              Positioned(top: 0, right: 0, child: _editCircleButton(() {})),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Review Stars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "3 Review  ",
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),
            ...List.generate(
              5,
                  (index) =>
              const Icon(Icons.star, color: AppColors.starColor, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Chips Row
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
              onTap: () {},
              backgroundColor: colorScheme.primary,
              icon: Icons.qr_code,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Change Subscription Button
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
  Widget _buildDescriptionCard(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Text(
                "Marland Clutch, founded in 1931, is a prominent global manufacturer specializing in heavy duty industrial backstopping and overrunning clutches...",
                style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: _editCircleButton(() {}, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PHOTO GRID =================
  Widget _buildPhotoGrid() {
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
                      () => setState(() => _apiPhotos.removeAt(index)),
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
                    () => setState(() => _photos.removeAt(localIndex)),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
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
                        Icon(Icons.location_on_outlined, color: colorScheme.primary, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "237 S 18th St, Philadelphia, PA 19103",
                            style: AppTextStyle.textXs(
                              color:  AppColors.base50,
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
                  style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant, weight: FontWeight.w400),
                ),
                Text(
                  "Credit remain: 10",
                  style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant, weight: FontWeight.w400),
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

  // ================= PHOTO PICKER =================
  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: () => _showSimplePicker((file) => setState(() => _photos.add(file))),
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
  Widget _buildSectionHeader(String title, {bool showViewAll = false, VoidCallback? onTap}) {
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
                style: AppTextStyle.textXs(
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= EDIT CIRCLE BUTTON =================
  Widget _editCircleButton(
      VoidCallback onTap, {
        double size = 26,
        IconData icon = Icons.edit_outlined,
        Color iconColor = AppColors.primaryG700,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, size: size * 0.7, color: iconColor),
      ),
    );
  }

  // ================= IMAGE PICKER =================
  void _showSimplePicker(Function(File) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) onSelected(File(picked.path));
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                if (picked != null) onSelected(File(picked.path));
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

