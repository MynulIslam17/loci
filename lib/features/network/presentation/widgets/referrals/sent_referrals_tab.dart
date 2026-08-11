import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:loci/features/network/presentation/controllers/sent_referrals_controller.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';
import 'package:loci/features/network/presentation/widgets/referrals/referral_card.dart';
import 'package:loci/features/network/presentation/widgets/network_list_shimmer.dart';

class SentReferralsTab extends StatefulWidget {
  const SentReferralsTab({super.key});

  @override
  State<SentReferralsTab> createState() => _SentReferralsTabState();
}

class _SentReferralsTabState extends State<SentReferralsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final controller = Get.find<SentReferralsController>();
    return Obx(() {
      if (controller.showInitialShimmer) {
        return const NetworkListShimmer();
      }

      if (controller.errorMessage != null && controller.referrals.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchSentReferrals(isRefresh: true),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: ErrorStateWidget(
                  message: controller.errorMessage!,
                  onRetry: controller.fetchSentReferrals,
                ),
              ),
            ),
          ),
        );
      }

      if (controller.referrals.isEmpty) {
        final hasSearch = controller.searchTerm.trim().isNotEmpty;

        return RefreshIndicator(
          onRefresh: () => controller.fetchSentReferrals(isRefresh: true),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: EmptyState(
                    icon: hasSearch
                        ? Icons.search_off_outlined
                        : Icons.send_outlined,
                    title: hasSearch
                        ? 'No matching referrals'
                        : 'No referrals sent yet',
                    subtitle: hasSearch
                        ? 'Try searching with a different keyword'
                        : null,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchSentReferrals(isRefresh: true),
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
              controller.loadMore();
            }
            return false;
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount:
                controller.referrals.length +
                (controller.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.referrals.length) {
                return const PaginationLoader();
              }
              return ReferralCard(referral: controller.referrals[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
        ),
      );
    });
  }
}
