import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
import 'package:loci/features/my_business/data/models/find_business_response.dart';
import 'package:loci/features/my_business/presentation/controllers/find_google_business_controller.dart';
import 'package:loci/features/my_business/presentation/widgets/business_search_result_widget.dart';
import 'package:loci/features/my_business/presentation/widgets/expandable_business_card.dart';
import 'package:loci/features/my_business/presentation/widgets/manual_add_business_card.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/routes/app_routes.dart';

import 'package:loci/features/my_business/presentation/controllers/get_my_business_list_controller.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
import '../widgets/my_business_card_shimmer.dart';

class SearchMyBusiness extends StatefulWidget {
  const SearchMyBusiness({super.key});

  @override
  State<SearchMyBusiness> createState() => _SearchMyBusinessState();
}

class _SearchMyBusinessState extends State<SearchMyBusiness> {
  final myBusinessController = Get.find<GetMyBusinessController>();
  final findGoogleBusinessController = Get.find<FindGoogleBusinessController>();
  final TextEditingController _searchTEController = TextEditingController();

  final selectedCategory = Rxn<BusinessCategory>();
  final expandedIndex = Rxn<int>();

  bool get _canAdd =>
      findGoogleBusinessController.selectedBusiness.value != null;

  void _onSearchChanged(String value) {
    findGoogleBusinessController.searchBusinesses(value);
  }

  void _onBusinessSelected(Business business) {
    _searchTEController.text = business.name;
    findGoogleBusinessController.selectBusiness(business);
  }

  void _onClearSelectedBusiness() {
    _searchTEController.clear();
    findGoogleBusinessController.clearSelectedBusiness();
  }

  Future<void> _onAddPressed() async {
    final business = findGoogleBusinessController.selectedBusiness.value;
    if (business == null) return;

    final result = await Get.toNamed(
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

    _handleClaimResult(result);
  }

  /// Called when a claim/create flow returns. Shows the server's own
  /// message, resets the search field to its default state, and refreshes
  /// the claimed-business list so the new entry shows up.
  void _handleClaimResult(dynamic result) {
    if (!mounted || result is! Map || result['success'] != true) return;

    // Reset the search box + any selected business to default state.
    _searchTEController.clear();
    findGoogleBusinessController.clearSelectedBusiness();

    // Surface the returned message (e.g. "Claim submitted for review...").
    final message = result['message'] as String?;
    if (message != null && message.isNotEmpty) {
      SnackbarService.success(message);
    }

    // Claiming a business promotes a member to business_owner on the backend —
    // refresh the session so subscription features unlock without a re-login.
    Get.find<AuthController>().refreshUser();

    // Reload so the freshly claimed business appears in the list.
    myBusinessController.getMyBusinesses(
      category: selectedCategory.value?.label,
    );
  }

  // --- Actions ----------------------------------------------------------------

  void _onCategoryChanged(BusinessCategory? value) {
    selectedCategory.value = value;
    myBusinessController.getMyBusinesses(category: value?.label);
  }

  void _retry() {
    myBusinessController.getMyBusinesses(
      category: selectedCategory.value?.label,
    );
  }

  Future<void> _onViewPageHandler({
    required String businessId,
    required String businessName,
  }) async {
    final result = await Get.toNamed(
      AppRoutes.myBusinessProfile,
      arguments: {'businessId': businessId, 'businessName': businessName},
    );

    if (!mounted) return;
    if (result is! Map || result['updated'] != true) return;

    final profile = result['profile'];
    if (profile is BusinessProfileModel) {
      myBusinessController.applyProfileSnapshot(profile);
    }
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
      body: Obx(() {
        final controller = myBusinessController;
        // Track google search selection for header (_canAdd).
        findGoogleBusinessController.selectedBusiness.value;
        // Category filter stays visible for business owners (including "All"
        // with an empty list) so they can switch categories without the
        // dropdown disappearing.
        final showFilter =
            controller.isBusinessOwner.value &&
            controller.errorMessage.value == null;

        // Read expand-state synchronously so this Obx subscribes to it. It's
        // otherwise only read inside the sliver's lazy itemBuilder (which runs
        // during layout, after this builder returns), so tapping to expand
        // wouldn't rebuild until another observable changed (e.g. a refresh).
        final currentExpandedIndex = expandedIndex.value;

        return RefreshIndicator(
          onRefresh: () => myBusinessController.getMyBusinesses(
            category: selectedCategory.value?.label,
            isRefresh: true,
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(colorScheme)),
              if (showFilter)
                SliverToBoxAdapter(child: _buildCategoryFilter(colorScheme)),

              _buildBody(controller, colorScheme, currentExpandedIndex),
            ],
          ),
        );
      }),
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
                    BusinessSearchResultWidget(onSelect: _onBusinessSelected),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor: colorScheme.onSurface.withValues(
                    alpha: 0.12,
                  ),
                  disabledForegroundColor: colorScheme.onSurface.withValues(
                    alpha: 0.38,
                  ),
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
          ManualAddBusinessCard(
            onTap: () async {
              final result = await Get.toNamed(AppRoutes.manualClaimBusiness);
              _handleClaimResult(result);
            },
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
          child: CustomDropdown<BusinessCategory?>(
            dropdownColor: colorScheme.surfaceContainerHigh,
            borderColor: colorScheme.outline,
            hintColor: colorScheme.onSurfaceVariant,
            textColor: colorScheme.onSurface,
            value: selectedCategory.value,
            onChanged: _onCategoryChanged,
            items: [
              const DropdownMenuItem<BusinessCategory?>(
                value: null,
                child: Text('All'),
              ),
              ...BusinessCategory.values.map(
                (category) => DropdownMenuItem<BusinessCategory?>(
                  value: category,
                  child: Text(category.label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Body (single source of truth for all states) --------------------------

  Widget _buildBody(
    GetMyBusinessController controller,
    ColorScheme colorScheme,
    int? expandedIndexValue,
  ) {
    if (!controller.isBusinessOwner.value) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: EmptyState(
            icon: Icons.lock_outline,
            title: 'You are not a business owner',
            subtitle: 'Claim a business to manage it here.',
          ),
        ),
      );
    }

    if (controller.showInitialShimmer) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, _) => const MyBusinessCardShimmer(),
          childCount: 4,
        ),
      );
    }

    if (controller.errorMessage.value != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: _retry,
          ),
        ),
      );
    }

    if (controller.businessList.isEmpty) {
      final isFiltering = selectedCategory.value != null;
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: EmptyState(
            icon: isFiltering
                ? Icons.search_off_outlined
                : Icons.storefront_outlined,
            title: isFiltering
                ? 'No businesses in this category'
                : 'No business claimed yet',
            subtitle: isFiltering
                ? 'Try a different category or clear the filter.'
                : 'Use the search above to claim your first business.',
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final business = controller.businessList[index];
        return ExpandableBusinessCard(
          isExpanded: expandedIndexValue == index,
          businessName: business.name,
          category: business.category,
          imagePath: business.logo ?? "",
          description: business.description ?? "",
          onTap: () =>
              expandedIndex.value = (expandedIndex.value == index) ? null : index,
          onViewPage: () => _onViewPageHandler(
            businessId: business.id,
            businessName: business.name,
          ),
        );
      }, childCount: controller.businessList.length),
    );
  }
}
