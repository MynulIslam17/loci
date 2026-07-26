import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/my_business/data/models/find_business_response.dart';
import 'package:loci/features/my_business/presentation/controllers/find_google_business_controller.dart';
import 'package:loci/shared/widgets/paginated_search_list.dart';

/// Compact search dropdown shown directly below the search text field.
class BusinessSearchResultWidget extends StatelessWidget {
  final void Function(Business business)? onSelect;

  const BusinessSearchResultWidget({super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Obx(() {
      final controller = Get.find<FindGoogleBusinessController>();
      if (!controller.showResults.value) return const SizedBox.shrink();

      return PaginatedSearchDropdown<Business>(
        items: controller.items,
        scrollController: controller.scrollController,
        isLoading: controller.isLoading.value,
        isLoadingMore: controller.isLoadingMore.value,
        errorMessage: controller.errorMessage.value,
        onRetry: () => controller.fetchPage(),
        maxHeight: 220,
        emptyWidget: controller.isLoading.value
            ? null
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No businesses found',
                    style: AppTextStyle.textSm(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
        itemBuilder: (context, business, index) {
          final isSelected =
              controller.selectedBusiness.value?.placeId == business.placeId;
          return _BusinessSearchResultTile(
            business: business,
            colorScheme: colorScheme,
            isSelected: isSelected,
            onTap: onSelect != null ? () => onSelect!(business) : null,
          );
        },
      );
    });
  }
}

class _BusinessSearchResultTile extends StatelessWidget {
  final Business business;
  final ColorScheme colorScheme;
  final bool isSelected;
  final VoidCallback? onTap;

  const _BusinessSearchResultTile({
    required this.business,
    required this.colorScheme,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? colorScheme.primary.withValues(alpha: 0.08) : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: AppTextStyle.textSm(color: colorScheme.onSurface),
                  children: [
                    TextSpan(
                      text: business.name,
                      style: AppTextStyle.textSm(
                        weight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: ' ${business.location}',
                      style: AppTextStyle.textSm(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
