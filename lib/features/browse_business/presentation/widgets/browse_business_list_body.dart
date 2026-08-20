import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/browse_business/presentation/controllers/browse_business_controller.dart';
import 'package:loci/features/browse_business/presentation/controllers/save_business_controller.dart';
import 'package:loci/features/browse_business/presentation/widgets/browse_business_card.dart';
import 'package:loci/features/browse_business/presentation/widgets/browse_shimmer.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';

class BrowseBusinessListBody extends StatelessWidget {
  const BrowseBusinessListBody({
    super.key,
    required this.controller,
    required this.expandedIndex,
    required this.emptyMinHeight,
    required this.onRetry,
  });

  final BrowseBusinessController controller;
  final RxInt expandedIndex;
  final double emptyMinHeight;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.showInitialShimmer) {
        return const BrowseShimmer();
      }

      if (controller.errorMessage.value != null &&
          controller.businesses.isEmpty) {
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: emptyMinHeight),
          child: Center(
            child: ErrorStateWidget(
              message: controller.errorMessage.value!,
              onRetry: onRetry,
            ),
          ),
        );
      }

      if (controller.businesses.isEmpty) {
        final hasSearch = controller.searchQuery.trim().isNotEmpty;

        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: emptyMinHeight),
          child: Center(
            child: EmptyState(
              icon: hasSearch
                  ? Icons.search_off_outlined
                  : Icons.storefront_outlined,
              title: hasSearch
                  ? 'No matching businesses'
                  : 'No businesses found',
              subtitle: hasSearch
                  ? 'Try searching with a different name or category.'
                  : 'Try a different category or pull to refresh.',
            ),
          ),
        );
      }

      return _BrowseBusinessList(
        controller: controller,
        expandedIndex: expandedIndex,
      );
    });
  }
}

class _BrowseBusinessList extends StatelessWidget {
  const _BrowseBusinessList({
    required this.controller,
    required this.expandedIndex,
  });

  final BrowseBusinessController controller;
  final RxInt expandedIndex;

  @override
  Widget build(BuildContext context) {
    final saveController = Get.find<SaveBusinessController>();

    return Obx(() {
      final itemCount = controller.businesses.length +
          (controller.isPaginationLoading.value ? 1 : 0);

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= controller.businesses.length) {
            return const PaginationLoader();
          }

          final item = controller.businesses[index];

          return Obx(
            () => BrowseBusinessCard(
              item: item,
              isExpanded: index == expandedIndex.value,
              onTap: () {
                FocusScope.of(context).unfocus();
                expandedIndex.value = index;
              },
              onAdd: () => saveController.saveBusiness(item.id),
              onView: () {
                FocusScope.of(context).unfocus();
                Get.toNamed(
                  AppRoutes.businessProfile,
                  arguments: {'businessId': item.id},
                );
              },
            ),
          );
        },
      );
    });
  }
}
