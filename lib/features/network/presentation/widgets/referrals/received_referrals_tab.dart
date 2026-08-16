import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/action_type.dart';

import 'package:loci/features/network/presentation/controllers/received_referrals_controller.dart';
import 'package:loci/features/network/presentation/controllers/respond_referral_controller.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';
import 'package:loci/features/network/presentation/widgets/referrals/referral_invitation_card.dart';
import 'package:loci/features/network/presentation/widgets/network_list_shimmer.dart';

class ReceivedReferralsTab extends StatefulWidget {
  const ReceivedReferralsTab({super.key});

  @override
  State<ReceivedReferralsTab> createState() => _ReceivedReferralsTabState();
}

class _ReceivedReferralsTabState extends State<ReceivedReferralsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final controller = Get.find<ReceivedReferralsController>();
    return Obx(() {
      if (controller.showInitialShimmer) {
        return const NetworkListShimmer();
      }

      if (controller.errorMessage != null && controller.referrals.isEmpty) {
        return AdaptiveRefresh(
          onRefresh: () => controller.fetchReceivedReferrals(isRefresh: true),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: ErrorStateWidget(
                  message: controller.errorMessage!,
                  onRetry: controller.fetchReceivedReferrals,
                ),
              ),
            ),
          ),
        );
      }

      if (controller.referrals.isEmpty) {
        final hasSearch = controller.searchTerm.trim().isNotEmpty;

        return AdaptiveRefresh(
          onRefresh: () => controller.fetchReceivedReferrals(isRefresh: true),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: EmptyState(
                    icon: hasSearch
                        ? Icons.search_off_outlined
                        : Icons.inbox_outlined,
                    title: hasSearch
                        ? 'No matching referrals'
                        : 'No referrals received yet',
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

      return AdaptiveRefresh(
        onRefresh: () => controller.fetchReceivedReferrals(isRefresh: true),
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
              final referral = controller.referrals[index];
              final respondController = Get.find<RespondReferralController>();
              return Obx(() {
                final responding = respondController.isResponding(referral.id);
                return ReferralInvitationCard(
                  referral: referral,
                  isAccepting: respondController.isAccepting(referral.id),
                  isRejecting: respondController.isRejecting(referral.id),
                  onConfirm: responding
                      ? null
                      : () => respondController.respond(
                          referral.id,
                          ActionType.accept.value,
                        ),
                  onReject: responding
                      ? null
                      : () => respondController.respond(
                          referral.id,
                          ActionType.reject.value,
                        ),
                );
              });
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
        ),
      );
    });
  }
}
