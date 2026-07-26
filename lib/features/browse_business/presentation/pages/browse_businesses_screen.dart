import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/browse_business/presentation/controllers/browse_business_controller.dart';
import 'package:loci/features/browse_business/presentation/widgets/browse_business_card.dart';
import 'package:loci/features/browse_business/presentation/widgets/browse_shimmer.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';

import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/features/browse_business/presentation/controllers/save_business_controller.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/error_state.dart';

class BrowseBusinesses extends StatefulWidget {
  const BrowseBusinesses({super.key});

  @override
  State<BrowseBusinesses> createState() => _BrowseBusinessesState();
}

class _BrowseBusinessesState extends State<BrowseBusinesses> {
  final BrowseBusinessController browseBusinessController =
      Get.find<BrowseBusinessController>();

  final saveController = Get.find<SaveBusinessController>();

  final ScrollController _scrollController = ScrollController();

  final expandedIndex = 0.obs;
  late final Rx<BusinessCategory> selectedCategory;

  @override
  void initState() {
    super.initState();

    final arg = Get.arguments;

    if (arg != null && arg is BusinessCategory) {
      selectedCategory = arg.obs;
    } else {
      selectedCategory = BusinessCategory.foodie.obs;
    }

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: CustomAppbar(title: "Browse business"),
      body: Obx(() {
        final controller = browseBusinessController;
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TOP SECTION =================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      borderColor: context.colorScheme.outline,
                      hintText: "Search Business",
                      hintTextColor: context.colorScheme.onSurfaceVariant,
                      textColor: context.colorScheme.onSurface,
                      suffixIcon: Icon(
                        Icons.search,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: size.width * 0.7,
                      child: Obx(
                        () => CustomDropdown<BusinessCategory>(
                          borderColor: context.colorScheme.outline,
                          dropdownColor:
                              context.colorScheme.surfaceContainerHigh,
                          fillColor: context.colorScheme.surface,
                          hintText: "Select Category",
                          items: BusinessCategory.values
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category.label,
                                    style: AppTextStyle.textXs(
                                      color: context.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          value: selectedCategory.value,
                          onChanged: (value) {
                            selectedCategory.value = value!;
                            expandedIndex.value = 0;
                            browseBusinessController.changeCategory(value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= BODY =================
              if (controller.isLoading.value)
                BrowseShimmer()
              else if (controller.errorMessage.value != null &&
                  controller.businesses.isEmpty)
                ErrorStateWidget(
                  message: controller.errorMessage.value!,
                  onRetry: () => controller.fetchBusinesses(
                    selectedCategory.value,
                    isRefresh: true,
                  ),
                )
              else if (controller.businesses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text("No businesses found"),
                  ),
                )
              else
                _buildBusiness(controller),
            ],
          ),
        );
      }),
    );
  }

  // ================= business =================
  Widget _buildBusiness(BrowseBusinessController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount:
          controller.businesses.length +
          (controller.isPaginationLoading.value ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == controller.businesses.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = controller.businesses[index];

        return Obx(
          () => BrowseBusinessCard(
            item: item,
            isExpanded: index == expandedIndex.value,
            onTap: () {
              expandedIndex.value = index;
            },
            onAdd: () => _addToListHandler(item.id),
            onView: () => _viewBusinessHandler(item.id),
          ),
        );
      },
    );
  }

  // ================= ACTIONS =================
  void _viewBusinessHandler(String businessId) {
    Get.toNamed(
      AppRoutes.businessProfile,
      arguments: {"businessId": businessId},
    );
  }

  void _addToListHandler(String businessId) async {
    bool success = await saveController.saveBusiness(businessId);
  }
}
