import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../core/theme/app_colors.dart';

class SearchMyBusiness extends StatefulWidget {
  const SearchMyBusiness({super.key});

  @override
  State<SearchMyBusiness> createState() => _SearchMyBusinessState();
}

class _SearchMyBusinessState extends State<SearchMyBusiness> {
  final List<String> categoryList = ["food", "entertainment", "tourism"];

  String? selectedCategory;
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Search My Business",
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔎 --- Search Bar Row ---
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomTextField(
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
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(Icons.add, color: colorScheme.onPrimary),
                        onPressed: () {
                          Get.toNamed(AppRoutes.clamBusinessProfile,arguments: {
                            'isFromManualClaim':false
                          });
                        },
                        label: const Text("Add"),
                      ),
                    ],
                  ),

                  //  Manual Add Option ---
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.05), // Very light tint of your brand color
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.business_center_outlined,
                              size: 18,
                              color: colorScheme.primary
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Can't find your business?",
                                style: AppTextStyle.textSm(weight: FontWeight.w500),
                              ),
                              Text(
                                "Create a new listing manually",
                                style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.manualClaimBusiness),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Row(
                            children: [
                              Text("Add Now", style: AppTextStyle.textSm(weight: FontWeight.w600)),
                              const Icon(Icons.chevron_right, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Category Dropdown ---
                  SizedBox(
                    width: 200,
                    child: Card(
                      color: colorScheme.surfaceContainerHigh,
                      child: CustomDropdown(
                        dropdownColor: colorScheme.surfaceContainerHigh,
                        value: selectedCategory,
                        borderColor: colorScheme.outline,
                        hintText: "Select Category",
                        textFontSize: 14,
                        hintFontSize: 14,
                        hintColor: colorScheme.onSurfaceVariant,
                        textColor: colorScheme.onSurface,
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        items: categoryList
                            .map(
                              (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // --- Business List ---
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildExpandableBusinessCard(
                colorScheme: colorScheme,
                index: index,
                isExpanded: _expandedIndex == index,
                businessName: "Marland Clutch $index",
                imagePath: "assets/images/company_logo.png",
                description:
                "Marland Clutch, founded in 1931, is a prominent global manufacturer...",
                onViewPage: () {
                  print("Navigate to Marland Clutch $index details");
                },
              ),
              childCount: 5,
            ),
          ),
        ],
      ),
    );
  }

  // --- Expandable Business Card ---
  Widget _buildExpandableBusinessCard({
    required ColorScheme colorScheme,
    required String businessName,
    required String description,
    required String imagePath,
    required VoidCallback onViewPage,
    required int index,
    required bool isExpanded,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _expandedIndex = (_expandedIndex == index) ? null : index;
          });
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          color: colorScheme.surfaceContainerHigh,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomCachedImage(
                    width: double.infinity,
                    height: 190,
                    imageUrl: imagePath,
                  ),
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          businessName,
                          style: AppTextStyle.textSm(
                            weight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: AppTextStyle.textXs(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionRow(
                          icon: Icons.visibility_outlined,
                          label: "View Your Business Page",
                          color: colorScheme.primary,
                          onTap: onViewPage,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyle.textSm(
                weight: FontWeight.w500,
              ).copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}