import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:loci/features/explore_activity/presentation/utils/explore_activity_search_focus.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class ExploreActivityHeader extends StatelessWidget {
  const ExploreActivityHeader({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchHint,
    required this.onSearchChanged,
    required this.searchFocus,
  });

  final String businessId;
  final String businessName;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final ExploreActivitySearchFocus searchFocus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: searchController,
            focusNode: searchFocusNode,
            onChanged: onSearchChanged,
            showClearButton: true,
            borderColor: colorScheme.outline,
            hintText: searchHint,
            hintTextColor: colorScheme.onSurfaceVariant,
            textColor: colorScheme.onSurface,
            suffixIcon: Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            backgroundColor: colorScheme.primary,
            onPressed: () {
              searchFocus.guard(
                () => Get.toNamed(
                  AppRoutes.createActivity,
                  arguments: {
                    'businessName': businessName,
                    'businessId': businessId,
                  },
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: colorScheme.onPrimary, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Create New Activity',
                  style: AppTextStyle.textSm(
                    weight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Explore Activities',
            style: AppTextStyle.textLg(
              weight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track ongoing activities like events, routes or raffles',
            style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  StickyTabBarDelegate(this.tabBar, {required this.color});

  final TabBar tabBar;
  final Color color;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(color: color, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant StickyTabBarDelegate oldDelegate) => false;
}
