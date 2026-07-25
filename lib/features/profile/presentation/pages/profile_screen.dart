import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/custom_imagepicker.dart';

import 'package:loci/features/profile/presentation/controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController _controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      body: Obx(() {
        final c = _controller;
        return RefreshIndicator(
          onRefresh: _controller.silentFetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

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
                        imageFile: c.profileImage,
                        imageUrl: c.profileImageUrl,
                        height: 110,
                        width: 110,
                        isCircle: true,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: _editButton(
                        onTap: () => CustomImagePicker.pickImageSimple(
                          context: context,
                          onImageSelected: c.updateImage,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ================= USER NAME =================
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        c.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.textXl(
                          color: colorScheme.primary,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: _editButton(
                        onTap: () => _showEditBottomSheet(
                          context: context,
                          title: "Edit Name",
                          hintText: "Edit Name",
                          initialValue: c.userName,
                          onSave: c.updateName,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                if (c.memberSince.isNotEmpty)
                  Text(
                    "Member since ${c.memberSince}",
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                const SizedBox(height: 20),

                // ================= ABOUT =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "About",
                      style: AppTextStyle.textMd(color: colorScheme.onSurface),
                    ),
                    const SizedBox(width: 5),
                    _editButton(
                      onTap: () => _showEditBottomSheet(
                        context: context,
                        title: "Edit About",
                        hintText: "Edit About",
                        initialValue: c.about,
                        maxLines: 3,
                        onSave: c.updateAbout,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: colorScheme.surfaceContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        c.about,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= ACHIEVEMENTS =================
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Progress and achievements",
                    style: AppTextStyle.textXl(color: colorScheme.primary),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _buildStatCard(
                      title: "Events",
                      icon: "assets/icons/calander.svg",
                      value: c.stats?.eventsCheckedIn,
                      colorScheme: colorScheme,
                    ),
                    _buildStatCard(
                      title: "Routes",
                      icon: "assets/icons/map.svg",
                      value: c.stats?.routesCheckedIn,
                      colorScheme: colorScheme,
                    ),
                    _buildStatCard(
                      title: "Raffles",
                      icon: "assets/icons/rafel.svg",
                      value: c.stats?.rafflesWon,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ================= stats helper =================

  Widget _buildStatCard({
    required String title,
    required String icon,
    required int? value,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Card(
          color: colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                SvgPicture.asset(icon, width: 24),
                const SizedBox(height: 10),
                value == null
                    ? AppSkeleton.box(width: 28, height: 16)
                    : Text('$value'),
                const SizedBox(height: 10),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= EDIT BUTTON =================
  Widget _editButton({
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

  // ================= BOTTOM SHEET =================
  void _showEditBottomSheet({
    required BuildContext context,
    required String title,
    required String initialValue,
    required Function(String) onSave,
    String? hintText,
    int maxLines = 1,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditFieldSheet(
        title: title,
        hintText: hintText,
        initialValue: initialValue,
        maxLines: maxLines,
        onSave: onSave,
      ),
    );
  }
}

class _EditFieldSheet extends StatefulWidget {
  final String title;
  final String? hintText;
  final String initialValue;
  final int maxLines;
  final Function(String) onSave;

  const _EditFieldSheet({
    required this.title,
    required this.hintText,
    required this.initialValue,
    required this.maxLines,
    required this.onSave,
  });

  @override
  State<_EditFieldSheet> createState() => _EditFieldSheetState();
}

class _EditFieldSheetState extends State<_EditFieldSheet> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSave() {
    final value = _textController.text.trim();
    if (value != widget.initialValue) {
      widget.onSave(value);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _textController,
              maxLine: widget.maxLines,
              hintText: widget.hintText,
            ),
            const SizedBox(height: 15),
            CustomButton(text: "Save", onPressed: _onSave),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
