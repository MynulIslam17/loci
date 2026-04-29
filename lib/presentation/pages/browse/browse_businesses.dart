import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/presentation/controllers/browse_business/browse_business_controller.dart';
import 'package:loci/presentation/pages/browse/widgets/browse_business_card.dart';
import 'package:loci/presentation/pages/browse/widgets/browse_shimmer.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';

import '../../../core/theme/theme_extention.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/custom_image_container.dart';
import '../../widgets/custom_text_field.dart';

class BrowseBusinesses extends StatefulWidget {
  const BrowseBusinesses({super.key});

  @override
  State<BrowseBusinesses> createState() => _BrowseBusinessesState();
}

class _BrowseBusinessesState extends State<BrowseBusinesses> {
  final BrowseBusinessController browseBusinessController =
  Get.find<BrowseBusinessController>();

  int? expandedIndex;

  late BusinessCategory selectedCategory;

  @override
  void initState() {
    super.initState();

    final arg = Get.arguments;

    if (arg != null && arg is BusinessCategory) {
      selectedCategory = arg;
    } else {
      selectedCategory = BusinessCategory.foodie;
    }

    expandedIndex = 0;

  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Browse Businesses",
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
      ),

      body: GetBuilder<BrowseBusinessController>(
        builder: (controller) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= TOP SECTION =================
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        borderColor: context.colorScheme.outline,
                        hintText: "Search Event",
                        hintTextColor:
                        context.colorScheme.onSurfaceVariant,
                        textColor: context.colorScheme.onSurface,
                        suffixIcon: Icon(
                          Icons.search,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: size.width * 0.7,
                        child: CustomDropdown<BusinessCategory>(
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
                                  color:
                                  context.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          )
                              .toList(),
                          value: selectedCategory,
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                              expandedIndex = 0;
                              browseBusinessController
                                  .changeCategory(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= BODY =================
                controller.isLoading
                    ? BrowseShimmer()
                    : controller.businesses.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text("No businesses found"),
                  ),
                )
                    : _buildBusiness(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= business  =================
  Widget _buildBusiness(BrowseBusinessController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.businesses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = controller.businesses[index];
        final isExpanded = index == expandedIndex;

        return BrowseBusinessCard(
          item: item,
          isExpanded: isExpanded,
          onTap: () {
            setState(() {
              expandedIndex = isExpanded ? null : index;
            });
          },
          onAdd: _addToListHandler,
          onView: _viewBusinessHandler,
        );
      },
    );
  }

  // ================= ACTIONS =================
  void _viewBusinessHandler() {
    Get.toNamed(AppRoutes.businessProfile);
  }

  void _addToListHandler() {}
}