import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffles_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/utils/explore_activity_search_focus.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_empty_sliver.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_list_footer.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_list_shimmer.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_tab_scroll.dart';
import 'package:loci/features/explore_activity/presentation/widgets/raffles_edit_card.dart';
import 'package:loci/features/raffles/data/models/raffle_list_model.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/error_state.dart';

class ExploreActivityRafflesTab extends StatefulWidget {
  const ExploreActivityRafflesTab({
    super.key,
    required this.businessId,
    required this.searchFocus,
  });

  final String businessId;
  final ExploreActivitySearchFocus searchFocus;

  @override
  State<ExploreActivityRafflesTab> createState() =>
      _ExploreActivityRafflesTabState();
}

class _ExploreActivityRafflesTabState extends State<ExploreActivityRafflesTab>
    with AutomaticKeepAliveClientMixin {
  final _controller = Get.find<BusinessRafflesListController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      return ExploreActivityTabScroll(
        isLoading: _controller.showInitialLoader(widget.businessId),
        isRefreshing: _controller.isRefreshing.value,
        isPaginationLoading: _controller.isPaginationLoading.value,
        onRefresh: () => _controller.fetchRaffles(
          businessId: widget.businessId,
          forceRefresh: true,
        ),
        onLoadMore: () =>
            _controller.loadMoreRaffles(businessId: widget.businessId),
        sliver: _buildSliver(),
      );
    });
  }

  Widget _buildSliver() {
    if (_controller.showInitialLoader(widget.businessId)) {
      return ExploreActivityListShimmer.sliver();
    }

    if (_controller.errorMessage.value != null &&
        _controller.raffleList.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorStateWidget(
          message: _controller.errorMessage.value!,
          onRetry: () => _controller.fetchRaffles(
            businessId: widget.businessId,
            forceRefresh: true,
          ),
        ),
      );
    }

    if (_controller.showEmptyState(widget.businessId)) {
      return const ExploreActivityEmptySliver(
        icon: Icons.card_giftcard_outlined,
        title: 'No raffles yet',
        subtitle: 'Create a raffle to see it here',
      );
    }

    return SliverList.separated(
      itemCount: _controller.raffleList.length + 1,
      itemBuilder: (context, index) {
        if (index == _controller.raffleList.length) {
          return ExploreActivityListFooter(
            isLoading: _controller.isPaginationLoading.value,
            hasMore: _controller.hasMore.value,
            endLabel: 'No more raffles',
          );
        }

        final raffle = _controller.raffleList[index];
        return RaffleEditCard(
          title: raffle.title,
          description: raffle.description,
          dateRange: _dateRange(raffle),
          prizeText: raffle.bundleName,
          imageUrl: raffle.banner,
          organizerName: raffle.organizerName,
          onEdit: () async {
            final result = await widget.searchFocus.guard(
              () => Get.toNamed(
                AppRoutes.editRaffles,
                arguments: {
                  'raffleId': raffle.id,
                  'businessId': widget.businessId,
                },
              ),
            );
            if (result == true) {
              await _controller.fetchRaffles(
                businessId: widget.businessId,
                forceRefresh: true,
              );
            }
          },
          onView: () {
            widget.searchFocus.guard(
              () => Get.toNamed(
                AppRoutes.viewRaffles,
                arguments: {
                  'raffleId': raffle.id,
                  'rafflesName': raffle.title,
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

  String _dateRange(RaffleModel model) {
    final startDate = DateTime.parse(model.startDate).toLocal();
    final endDate = DateTime.parse(model.endDate).toLocal();
    return '${DateParserHelper.shortDate(startDate)} - '
        '${DateParserHelper.shortDate(endDate)}';
  }
}
