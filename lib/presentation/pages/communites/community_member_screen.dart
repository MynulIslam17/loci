import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/dialog_helper.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

import '../../widgets/custom_text_field.dart';

class CommunityMemberScreen extends StatefulWidget {
  const CommunityMemberScreen({super.key});

  @override
  State<CommunityMemberScreen> createState() => _CommunityMemberScreenState();
}

class _CommunityMemberScreenState extends State<CommunityMemberScreen> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      // We use a CustomScrollView to make the entire page scrollable together
      appBar: CustomAppbar(title: "Community member"),
      body: CustomScrollView(
        slivers: [
          //  The Search Bar and "Add Member" Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search TextField
                  CustomTextField(
                    hintText: "Claim your Business",
                    borderColor: colorScheme.outline,
                    fontSize: 14,
                    textColor: colorScheme.onSurface,
                    hintTextColor: colorScheme.onSurfaceVariant,
                    suffixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Add Member Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Member",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF5CB8AC,
                        ), // Teal color from image
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //  The "Total member list" Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total member list",
                        style: AppTextStyle.textMd(
                          color: colorScheme.onSurface,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "480K member",
                        style: AppTextStyle.textSm(
                          color: colorScheme.onSurfaceVariant,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Save Button with Icon
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Text(
                      "Save",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    label: Icon(
                      Icons.file_download_outlined,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //  The List of Members
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildMemberCard();
                },
                childCount: 10, // Number of members in the list
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // A helper method to build the individual member cards
  Widget _buildMemberCard() {
    final colorScheme = context.colorScheme;
    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            CustomCachedImage(
              imageUrl: "assets/images/user1.png",
              isCircle: true,
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),

            // Member Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Alexandra Broke",
                    style: AppTextStyle.textMd(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildIconText(
                    Icons.business_center_outlined,
                    "VP of Sales at TechCorp",
                  ),
                  _buildIconText(Icons.email_outlined, "sarah.j@techcorp.com"),
                  _buildIconText(Icons.phone_outlined, "555-0101"),
                ],
              ),
            ),

            // Three dots menu (clickable)
            PopupMenuButton(
              onSelected: (value) {
                if (value == "Delete") {
                  showDeleteDialog(
                    context: context,
                    title: "Delete Member",
                    message: "Are you sure you want to remove Alexandra Broke?",
                    onDelete: () {},
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "Delete",
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text("Delete"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Small helper for the icon + text rows
  Widget _buildIconText(IconData icon, String text) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
