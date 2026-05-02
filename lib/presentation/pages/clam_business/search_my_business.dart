import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../core/theme/app_colors.dart';
import '../../controllers/my_business/get_my_business_list _controller.dart';
import '../../widgets/error_state.dart';

class SearchMyBusiness extends StatefulWidget {
  const SearchMyBusiness({super.key});

  @override
  State<SearchMyBusiness> createState() => _SearchMyBusinessState();
}

class _SearchMyBusinessState extends State<SearchMyBusiness> {
  final myBusinessController = Get.find<GetMyBusinessController>();

  BusinessCategory? selectedCategory;
  int? _expandedIndex;

  //---view page handler

  void _onViewPageHandler({
    required String businessId,
    required String businessName,
  }) async {
    final result = await Get.toNamed(
      AppRoutes.myBusinessProfile,
      arguments: {"businessId": businessId, "businessName": businessName},
    );

    // TODO : on success
    if (result != null && result["success"] == true) {}
  }

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
      body:CustomScrollView(
        slivers: [
          /// ================= HEADER =================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔎 SEARCH + ADD
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
                          Get.toNamed(
                            AppRoutes.clamBusinessProfile,
                            arguments: {'isFromManualClaim': false},
                          );
                        },
                        label: const Text("Add"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 📌 MANUAL ADD CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.05),
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
                          child: Icon(
                            Icons.business_center_outlined,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Can't find your business?",
                                style: AppTextStyle.textSm(
                                  weight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Create new listing manually",
                                style: AppTextStyle.textXs(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Get.toNamed(AppRoutes.manualClaimBusiness),
                          child: const Row(
                            children: [
                              Text("Add Now"),
                              Icon(Icons.chevron_right, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// 📂 CATEGORY DROPDOWN
                  SizedBox(
                    width: 200,
                    child: Card(
                      color: colorScheme.surfaceContainerHigh,
                      child: CustomDropdown<BusinessCategory>(
                        dropdownColor: colorScheme.surfaceContainerHigh,
                        borderColor: colorScheme.outline,
                        hintColor: colorScheme.onSurfaceVariant,
                        textColor: colorScheme.onSurface,
                        value: selectedCategory,
                        hintText: "Select Category",
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });

                          myBusinessController.getMyBusinesses(
                            category: value?.label,
                          );
                        },
                        items: BusinessCategory.values
                            .map(
                              (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.label),
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

          /// ================= STATE HANDLING =================
          SliverToBoxAdapter(
            child: GetBuilder<GetMyBusinessController>(
              builder: (controller) {
                /// NOT OWNER
                if (!controller.isBusinessOwner) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("You are not a business owner"),
                    ),
                  );
                }

                /// LOADING
                if (controller.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                /// ERROR
                if (controller.errorMessage != null) {
                  return ErrorStateWidget(
                    message: controller.errorMessage!,
                    onRetry: () => controller.getMyBusinesses(
                      category: selectedCategory?.label,
                    ),
                  );
                }

                /// EMPTY
                if (controller.businessList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("No business claimed yet"),
                    ),
                  );
                }

                /// SUCCESS PLACEHOLDER (LIST BELOW)
                return const SizedBox.shrink();
              },
            ),
          ),

          /// ================= BUSINESS LIST =================
          GetBuilder<GetMyBusinessController>(
            builder: (controller) {
              /// HIDE LIST IF NOT VALID
              if (!controller.isBusinessOwner ||
                  controller.isLoading ||
                  controller.errorMessage != null ||
                  controller.businessList.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox());
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final business = controller.businessList[index];

                    return _buildExpandableBusinessCard(
                      colorScheme: context.colorScheme,
                      index: index,
                      isExpanded: _expandedIndex == index,
                      businessName: business.name ?? "",
                      imagePath: business.logo ?? "",
                      description: business.description ?? "",
                      onViewPage: () => _onViewPageHandler(
                        businessId: business.id ?? "",
                        businessName: business.name ?? "",
                      ),
                    );
                  },
                  childCount: controller.businessList.length,
                ),
              );
            },
          ),
        ],
      )
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
