import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/features/browse_business/presentation/controllers/browse_business_controller.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
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
  final expandedIndex = 0.obs;
  late final Rx<BusinessCategory> selectedCategory;

  @override
  void initState() {
    super.initState();

    final arg = Get.arguments;
    selectedCategory =
        (arg is BusinessCategory ? arg : BusinessCategory.foodie).obs;

    _searchController.text = browseBusinessController.searchQuery;

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
    _searchController.dispose();
    browseBusinessController.clearSearch();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(BusinessCategory value) {
    selectedCategory.value = value;
    expandedIndex.value = 0;
    browseBusinessController.changeCategory(value);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final emptyBodyMinHeight = size.height -
        MediaQuery.paddingOf(context).top -
        kToolbarHeight -
        132;

    return Scaffold(
      appBar: const CustomAppbar(title: 'Browse business'),
      body: RefreshIndicator(
        onRefresh: browseBusinessController.refreshData,
        child: SingleChildScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BrowseBusinessSearchHeader(
                screenWidth: size.width,
                searchController: _searchController,
                selectedCategory: selectedCategory,
                onCategoryChanged: _onCategoryChanged,
                onSearchChanged: browseBusinessController.onSearchChanged,
                onClearSearch: browseBusinessController.clearSearch,
              ),
              BrowseBusinessListBody(
                controller: browseBusinessController,
                expandedIndex: expandedIndex,
                emptyMinHeight: emptyBodyMinHeight,
                onRetry: () => browseBusinessController.fetchBusinesses(
                  selectedCategory.value,
                  isRefresh: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
