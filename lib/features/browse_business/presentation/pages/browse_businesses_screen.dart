import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/browse_business/presentation/controllers/browse_business_controller.dart';
import 'package:loci/shared/widgets/adaptive_expandable_search_header.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/modern_category_dropdown.dart';
import 'package:loci/features/browse_business/presentation/widgets/browse_business_list_body.dart';

class BrowseBusinesses extends StatefulWidget {
  const BrowseBusinesses({super.key});

  @override
  State<BrowseBusinesses> createState() => _BrowseBusinessesState();
}

class _BrowseBusinessesState extends State<BrowseBusinesses> {
  final browseBusinessController = Get.find<BrowseBusinessController>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchExpanded = false;
  final expandedIndex = 0.obs;
  late final Rx<BusinessCategory> selectedCategory;

  @override
  void initState() {
    super.initState();

    final arg = Get.arguments;
    final category = arg is BusinessCategory ? arg : BusinessCategory.foodie;
    selectedCategory = category.obs;

    _searchController.text = '';
    _isSearchExpanded = false;

    // Ensure previous category data is cleared immediately and shimmer is shown
    browseBusinessController.initForCategory(category);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !browseBusinessController.isPaginationLoading.value &&
          browseBusinessController.hasMore) {
        browseBusinessController.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    browseBusinessController.clearSearch();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(BusinessCategory? value) {
    if (value == null) return;
    selectedCategory.value = value;
    expandedIndex.value = 0;
    _searchController.clear();
    _isSearchExpanded = false;
    browseBusinessController.changeCategory(value);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final colors = context.colorScheme;
    final emptyBodyMinHeight = size.height -
        MediaQuery.paddingOf(context).top -
        kToolbarHeight -
        150;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const CustomAppbar(title: 'Browse business'),
      body: AdaptiveRefresh(
        color: colors.primary,
        onRefresh: browseBusinessController.refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── 1. Floating Quick-Return Search Header (iOS Glass / Android M3) ─
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: AdaptivePinnedSearchDelegate(
                child: AdaptiveExpandableSearchHeader(
                  title: 'Browse Business',
                  subtitle: 'Explore local businesses and services',
                  hintText: 'Search business...',
                  searchController: _searchController,
                  searchFocus: _searchFocus,
                  isExpanded: _isSearchExpanded ||
                      browseBusinessController.searchQuery.isNotEmpty,
                  onToggleExpand: (expanded) {
                    setState(() => _isSearchExpanded = expanded);
                  },
                  onSearchChanged: browseBusinessController.onSearchChanged,
                  onClear: () {
                    browseBusinessController.clearSearch();
                  },
                ),
              ),
            ),

            // ── 2. Modern Category Filter Bar ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Obx(
                    () => ModernCategoryDropdown(
                      selectedCategory: selectedCategory.value,
                      label: 'Filter Category',
                      onChanged: _onCategoryChanged,
                    ),
                  ),
                ),
              ),
            ),

            // ── 3. Content Body (Skeletons / Error / Empty / List) ─────────
            SliverToBoxAdapter(
              child: BrowseBusinessListBody(
                controller: browseBusinessController,
                expandedIndex: expandedIndex,
                emptyMinHeight: emptyBodyMinHeight,
                onRetry: () => browseBusinessController.fetchBusinesses(
                  selectedCategory.value,
                  isRefresh: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
