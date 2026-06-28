import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/busniess/find_business_response.dart';
import 'package:loci/presentation/controllers/my_business/find_google_business_controller.dart';
import 'package:loci/presentation/pages/clam_business/widgets/business_search_result_widget.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:loci/routes/app_routes.dart';

import '../../controllers/my_business/get_my_business_list _controller.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/error_state.dart';
import 'widgets/my_business_card_shimmer.dart';

class SearchMyBusiness extends StatefulWidget {
  const SearchMyBusiness({super.key});

  @override
  State<SearchMyBusiness> createState() => _SearchMyBusinessState();
}

class _SearchMyBusinessState extends State<SearchMyBusiness> {
  final myBusinessController = Get.find<GetMyBusinessController>();
  final findGoogleBusinessController = Get.find<FindGoogleBusinessController>();
  final TextEditingController _searchTEController = TextEditingController();

  BusinessCategory? selectedCategory;
  int? _expandedIndex;

  bool get _canAdd => findGoogleBusinessController.selectedBusiness != null;

  void _onSearchChanged(String value) {
    findGoogleBusinessController.searchBusinesses(value);
    setState(() {});
  }

  void _onBusinessSelected(Business business) {
    _searchTEController.text = business.name;
    findGoogleBusinessController.selectBusiness(business);
    setState(() {});
  }

  void _onClearSelectedBusiness() {
    _searchTEController.clear();
    findGoogleBusinessController.clearSelectedBusiness();
    setState(() {});
  }

  void _onAddPressed() {
    final business = findGoogleBusinessController.selectedBusiness;
    if (business == null) return;

    Get.toNamed(
      AppRoutes.clamBusinessProfile,
      arguments: {
        'placeId': business.placeId,
        'name': business.name,
        'location': business.location,
        'phone': business.phone,
        'website': business.website,
        'description': business.description,
        'logo': business.logo,
        'suggestedCategory': business.suggestedCategory,
      },
    );
  }

  // --- Actions ----------------------------------------------------------------

  void _onCategoryChanged(BusinessCategory? value) {
    setState(() => selectedCategory = value);
    myBusinessController.getMyBusinesses(category: value?.label);
  }

  void _retry() {
    myBusinessController.getMyBusinesses(category: selectedCategory?.label);
  }

  Future<void> _onViewPageHandler({
    required String businessId,
    required String businessName,
  }) async {
    await Get.toNamed(
      AppRoutes.myBusinessProfile,
      arguments: {"businessId": businessId, "businessName": businessName},
    );
  }

  @override
  void dispose() {
    _searchTEController.dispose();
    super.dispose();
  }

  // --- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Search My Business"),
      body: GetBuilder<GetMyBusinessController>(
        builder: (controller) {
          // Only show the category filter when there is something to filter,
          // OR a filter is already applied (so the user can change/clear it).
          final showFilter = controller.isBusinessOwner &&
              controller.errorMessage == null &&
              (selectedCategory != null || controller.businessList.isNotEmpty);

          return RefreshIndicator(
            onRefresh: () => myBusinessController.getMyBusinesses(
              category: selectedCategory?.label,
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(colorScheme)),
                if (showFilter)
                  SliverToBoxAdapter(child: _buildCategoryFilter(colorScheme)),

                _buildBody(controller, colorScheme),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Header -----------------------------------------------------------------

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// SEARCH + ADD
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _searchTEController,
                      hintText: 'Claim your Business',
                      borderColor: colorScheme.outline,
                      fontSize: 14,
                      textColor: colorScheme.onSurface,
                      hintTextColor: colorScheme.onSurfaceVariant,
                      readOnly: _canAdd,
                      onChanged: _onSearchChanged,
                      suffixIcon: _canAdd
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: _onClearSelectedBusiness,
                            )
                          : Icon(
                              Icons.search,
                              color: colorScheme.onSurfaceVariant,
                            ),
                    ),
                    const SizedBox(height: 4),
                    BusinessSearchResultWidget(
                      onSelect: _onBusinessSelected,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor:
                      colorScheme.onSurface.withValues(alpha: 0.12),
                  disabledForegroundColor:
                      colorScheme.onSurface.withValues(alpha: 0.38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  Icons.add,
                  color: _canAdd
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withValues(alpha: 0.38),
                ),
                onPressed: _canAdd ? _onAddPressed : null,
                label: const Text('Add'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// MANUAL ADD CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: colorScheme.primary.withOpacity(0.2)),
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
                        style: AppTextStyle.textSm(weight: FontWeight.w500),
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
        ],
      ),
    );
  }

  // --- Filter -----------------------------------------------------------------

  Widget _buildCategoryFilter(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 16),
      child: SizedBox(
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
            onChanged: _onCategoryChanged,
            items: BusinessCategory.values
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  // --- Body (single source of truth for all states) --------------------------

  Widget _buildBody(GetMyBusinessController controller, ColorScheme colorScheme) {
    if (!controller.isBusinessOwner) {
      return _fillMessage(
        icon: Icons.lock_outline,
        title: "You are not a business owner",
        subtitle: "Claim a business to manage it here.",
        colorScheme: colorScheme,
      );
    }

    if (controller.isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, _) => const MyBusinessCardShimmer(),
          childCount: 4,
        ),
      );
    }

    if (controller.errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorStateWidget(
          message: controller.errorMessage!,
          onRetry: _retry,
        ),
      );
    }

    if (controller.businessList.isEmpty) {
      final isFiltering = selectedCategory != null;
      return _fillMessage(
        icon: isFiltering
            ? Icons.search_off_outlined
            : Icons.storefront_outlined,
        title: isFiltering
            ? "No businesses in this category"
            : "No business claimed yet",
        subtitle: isFiltering
            ? "Try a different category or clear the filter."
            : "Use the search above to claim your first business.",
        colorScheme: colorScheme,
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final business = controller.businessList[index];
          return _buildExpandableBusinessCard(
            colorScheme: colorScheme,
            index: index,
            isExpanded: _expandedIndex == index,
            businessName: business.name,
            imagePath: business.logo ?? "",
            description: business.description ?? "",
            onViewPage: () => _onViewPageHandler(
              businessId: business.id,
              businessName: business.name,
            ),
          );
        },
        childCount: controller.businessList.length,
      ),
    );
  }

  Widget _fillMessage({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme colorScheme,
  }) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyle.textMd(weight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Expandable Business Card ----------------------------------------------

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
              style: AppTextStyle.textSm(weight: FontWeight.w500)
                  .copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
