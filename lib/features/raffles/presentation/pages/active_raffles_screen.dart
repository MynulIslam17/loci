import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/raffles/presentation/controllers/raffle_list_controller.dart';
import 'package:loci/features/raffles/presentation/widgets/raffle_card.dart';
import 'package:loci/features/raffles/presentation/widgets/raffle_card_skeleton.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';

/// List of active raffles shown inside the main shell drawer overlay.
class ActiveRafflesPage extends StatefulWidget {
  const ActiveRafflesPage({super.key});

  @override
  State<ActiveRafflesPage> createState() => _ActiveRafflesPageState();
}

class _ActiveRafflesPageState extends State<ActiveRafflesPage> {
  final raffleListController = Get.find<RaffleListController>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        raffleListController.loadMoreRaffles();
      }
    });

    _searchController.text = raffleListController.searchQuery;

    raffleListController.fetchRaffles(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocus.dispose();
    _searchController.dispose();
    raffleListController.clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CustomTextField(
            controller: _searchController,
            focusNode: _searchFocus,
            hintText: "Search Raffle",
            borderColor: colorScheme.outline,
            fontSize: 14,
            textColor: colorScheme.onSurface,
            hintTextColor: colorScheme.onSurfaceVariant,
            onChanged: raffleListController.onSearchChanged,
            showClearButton: true,
            onClear: () {
              _searchController.clear();
              raffleListController.clearSearch();
            },
            suffixIcon: Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Active Raffles",
            style: AppTextStyle.textXl(weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "Check in to locations to enter and win prizes",
            style: AppTextStyle.textSm(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: RefreshIndicator(
        onRefresh: () async {
          if (!raffleListController.isInitialLoading &&
              !raffleListController.isRefreshing) {
            await raffleListController.refreshRaffles();
          }
        },
        child: Obx(() {
          final controller = raffleListController;
          final hasSearch = controller.searchQuery.trim().isNotEmpty;
          final isInitialLoading = controller.showInitialShimmer;
          final hasFatalError =
              controller.errorMessage != null &&
              controller.raffleList.isEmpty &&
              !isInitialLoading;

          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (controller.isRefreshing)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (isInitialLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, _) => const RaffleCardSkeleton(),
                    childCount: 3,
                  ),
                )
              else if (hasFatalError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorStateWidget(
                    message: controller.errorMessage!,
                    onRetry: () => controller.fetchRaffles(isRefresh: true),
                  ),
                )
              else if (controller.raffleList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasSearch
                              ? Icons.search_off_outlined
                              : Icons.event_busy,
                          size: 48,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hasSearch
                              ? "No raffles match \"${controller.searchQuery}\""
                              : "No active raffles",
                          style: AppTextStyle.textSm(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Pagination loader
                      if (index == controller.raffleList.length) {
                        return const PaginationLoader();
                      }

                      final raffle = controller.raffleList[index];
                      return RaffleCard(
                        raffle: raffle,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Get.toNamed(
                            AppRoutes.rafflesDetails,
                            arguments: {'raffleId': raffle.id},
                          );
                        },
                      );
                    },
                    childCount:
                        controller.raffleList.length +
                        (controller.isPaginationLoading ? 1 : 0),
                  ),
                ),
            ],
          );
        }),
          ),
          ),
        ],
      ),
    );
  }
}
