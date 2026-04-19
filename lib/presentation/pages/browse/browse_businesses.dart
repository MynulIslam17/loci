import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
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

class BusinessItem {
  final String name;
  final String description;
  final String imageUrl;

  BusinessItem({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

class _BrowseBusinessesState extends State<BrowseBusinesses> {
  int? expandedIndex;

  List<String> _category = [
    "Boutiques  & Beauty",
    "Foodie",
    "Adventure",
    "Party Like raffles Loci",
    "Wellness",
    "Home and Repair",
    "Non Profits",
    "Local Services",
  ];

  String? selectedCategory;

  final List<BusinessItem> _dummyDataList = List.generate(100, (index) {
    return BusinessItem(
      name: "Business ${index + 1}",
      description: "Best service in town for category ${index % 8}" * 5,
      imageUrl: "https://picsum.photos/200/120?random=$index",
    );
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Browse Businesses", style: AppTextStyle.textLg(weight: FontWeight.w600)),
      ),
      // --- To scroll the entire body ---
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOP SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    borderColor: context.colorScheme.outline,
                    hintText: "Search Event",
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
                    child: CustomDropdown(
                      borderColor: context.colorScheme.outline,
                      dropdownColor: context.colorScheme.surfaceContainerHigh,
                      fillColor: context.colorScheme.surface,
                      hintText: "Select Category",
                      items: _category
                          .map(
                            (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: AppTextStyle.textXs(
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                      value: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --- BOTTOM SECTION ---

            _dummyDataList.isEmpty
                ? const Center(child: Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Text("No businesses found"),
            ))
                : _buildScrollableGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableGrid() {
    const int cols = 4;
    List<List<BusinessItem>> rowsList = [];

    for (int i = 0; i < _dummyDataList.length; i += cols) {
      rowsList.add(
        _dummyDataList.sublist(
          i,
          i + cols > _dummyDataList.length ? _dummyDataList.length : i + cols,
        ),
      );
    }

    //-- for scrolling horizontal ---
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rowsList.asMap().entries.map((rowEntry) {
          int rowIndex = rowEntry.key;
          List<BusinessItem> rowItems = rowEntry.value;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowItems.asMap().entries.map((itemEntry) {
              int colIndex = itemEntry.key;
              BusinessItem item = itemEntry.value;

              int globalIndex = (rowIndex * cols) + colIndex;
              bool isExpanded = expandedIndex == globalIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    expandedIndex = isExpanded ? null : globalIndex;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 6,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: isExpanded ? 300 : 260,
                    height: isExpanded ? 350 : 130,
                    child: Card(
                      elevation: isExpanded ? 8 : 2,
                      color: context.colorScheme.surfaceContainerHigh,
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                CustomCachedImage(
                                  width: double.infinity,
                                  height: 120,
                                  imageUrl: item.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                                if (isExpanded)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          expandedIndex = null;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isExpanded)
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: AppTextStyle.textSm(
                                          color: context.colorScheme.primary,
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.description,
                                        style: AppTextStyle.textXs(
                                          color: context.colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      TextButton.icon(
                                        onPressed:_addToListHandler,
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(7),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.add_circle_outline,
                                          color: context.colorScheme.onSurface,
                                        ),
                                        label: const Text("Add to list"),
                                      ),
                                      TextButton.icon(
                                        onPressed: _viewBusinessHandler,
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(7),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.remove_red_eye_outlined,
                                          color: context.colorScheme.onSurface,
                                        ),
                                        label: const Text("View Business Page"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }


  //-- for go to the business profile

  void _viewBusinessHandler()async{

    Get.toNamed(AppRoutes.businessProfile);



  }

  // --- save business add to list
  void _addToListHandler()async{



  }


}