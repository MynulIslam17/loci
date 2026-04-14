import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';

import '../../controllers/profile/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  final List<Map<String, dynamic>> achievementData = [
    {
      "icon": "assets/icons/calander.svg",
      "title": "Events",
      "value": (ProfileController c) => c.stats?.eventsCheckedIn ?? 0,
    },
    {
      "icon": "assets/icons/map.svg",
      "title": "Routes",
      "value": (ProfileController c) => c.stats?.routesCheckedIn ?? 0,
    },
    {
      "icon": "assets/icons/rafel.svg",
      "title": "Raffles",
      "value": (ProfileController c) => c.stats?.rafflesWon ?? 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      body: GetBuilder<ProfileController>(
        initState: (_) {
          Get.find<ProfileController>().silentFetchProfile();
        },
        builder: (c) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  await c.fetchProfile();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
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
                              onTap: () {
                                CustomImagePicker.pickImageSimple(
                                  context: context,
                                  onImageSelected: (file) {
                                    c.updateImage(file);
                                  },
                                );
                              },
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
                              onTap: () {
                                _showEditBottomSheet(
                                  context: context,
                                  title: "Edit Name",
                                  hintText: "Edit Name",
                                  initialValue: c.userName,
                                  onSave: (value) {
                                    c.updateName(value);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Member since December 23, 2021",
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
                            style: AppTextStyle.textMd(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 5),
                          _editButton(
                            onTap: () {
                              _showEditBottomSheet(
                                context: context,
                                title: "Edit About",
                                hintText: "Edit About",
                                initialValue: c.about,
                                maxLines: 3,
                                onSave: (value) {
                                  c.updateAbout(value);
                                },
                              );
                            },
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
                          style: AppTextStyle.textXl(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          _buildStatCard(
                            "Events",
                            "assets/icons/calander.svg",
                            c.isLoading ? "_" : "${c.stats?.eventsCheckedIn ?? 0}",
                            colorScheme,
                          ),

                          _buildStatCard(
                            "Routes",
                            "assets/icons/map.svg",
                            c.isLoading ? "_": "${c.stats?.routesCheckedIn ?? 0}",
                            colorScheme,
                          ),

                          _buildStatCard(
                            "Raffles",
                            "assets/icons/rafel.svg",
                            c.isLoading ? "_": "${c.stats?.rafflesWon ?? 0}",
                            colorScheme,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // ================= LOADER OVERLAY =================
              if (c.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  // ================= stats helper =================

  Widget _buildStatCard(
      String title,
      String icon,
      String value,
      ColorScheme colorScheme,
      ) {
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
                Text(value), // now String safe
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
    final textController = TextEditingController(text: initialValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
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
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  controller: textController,
                  maxLine: maxLines,
                  hintText: hintText,
                ),

                const SizedBox(height: 15),

                CustomButton(
                  text: "Save",
                  onPressed: () {
                    onSave(textController.text.trim());
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }







}
