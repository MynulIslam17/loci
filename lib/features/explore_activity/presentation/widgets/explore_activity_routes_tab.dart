import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/utils/explore_activity_search_focus.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_empty_sliver.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_list_footer.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_list_shimmer.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_tab_scroll.dart';
import 'package:loci/features/explore_activity/presentation/widgets/route_edit_card.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/error_state.dart';

class ExploreActivityRoutesTab extends StatefulWidget {
  const ExploreActivityRoutesTab({
    super.key,
    required this.businessId,
    required this.searchFocus,
  });

  final String businessId;
  final ExploreActivitySearchFocus searchFocus;

  @override
  State<ExploreActivityRoutesTab> createState() =>
      _ExploreActivityRoutesTabState();
}

class _ExploreActivityRoutesTabState extends State<ExploreActivityRoutesTab>
    with AutomaticKeepAliveClientMixin {
  final _controller = Get.find<BusinessRouteListController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      return ExploreActivityTabScroll(
        isLoading: _controller.showInitialLoader(widget.businessId),
        isPaginationLoading: _controller.isPaginationLoading.value,
        onRefresh: () => _controller.fetchRoutes(
          businessId: widget.businessId,
          forceRefresh: true,
        ),
        onLoadMore: () =>
            _controller.loadMoreRoutes(businessId: widget.businessId),
        sliver: _buildSliver(),
      );
    });
  }

  Widget _buildSliver() {
    if (_controller.showInitialLoader(widget.businessId)) {
      return ExploreActivityListShimmer.sliver();
    }

    if (_controller.errorMessage.value != null &&
        _controller.routeList.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorStateWidget(
          message: _controller.errorMessage.value!,
          onRetry: () => _controller.fetchRoutes(
            businessId: widget.businessId,
            forceRefresh: true,
          ),
        ),
      );
    }

    if (_controller.showEmptyState(widget.businessId)) {
      return const ExploreActivityEmptySliver(
        icon: Icons.route_outlined,
        title: 'No routes yet',
        subtitle: 'Create a route to see it here',
      );
    }

    return SliverList.separated(
      itemCount: _controller.routeList.length + 1,
      itemBuilder: (context, index) {
        if (index == _controller.routeList.length) {
          return ExploreActivityListFooter(
            isLoading: _controller.isPaginationLoading.value,
            hasMore: _controller.hasMore.value,
            endLabel: 'No more routes',
          );
        }

        final route = _controller.routeList[index];
        return RouteEditCard(
          imageUrl: route.banner,
          title: route.title,
          description: route.details,
          location: route.location,
          openingTime: route.openingTime,
          availabilityType: route.availabilityType,
          isPublic: route.isRoutePublic,
          onEdit: () async {
            final result = await widget.searchFocus.guard(
              () => Get.toNamed(
                AppRoutes.editRoutes,
                arguments: {
                  'routeName': route.title,
                  'routeId': route.routeId,
                  'businessId': widget.businessId,
                },
              ),
            );
            if (result == true) {
              await _controller.fetchRoutes(
                businessId: widget.businessId,
                forceRefresh: true,
              );
            }
          },
          onView: () {
            widget.searchFocus.guard(
              () => Get.toNamed(
                AppRoutes.viewRoutes,
                arguments: {
                  'routeName': route.title,
                  'routeId': route.routeId,
                  'businessId': widget.businessId,
                },
              ),
            );
          },
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
    );
  }
}
