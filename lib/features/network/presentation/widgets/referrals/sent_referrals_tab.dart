import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:loci/features/network/presentation/controllers/sent_referrals_controller.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
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
      if (controller.isLoading) {
        return const NetworkListShimmer();
      }

      if (controller.errorMessage != null && controller.referrals.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.fetchSentReferrals,
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
        return RefreshIndicator(
          onRefresh: controller.fetchSentReferrals,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: const Center(
                  child: EmptyState(
                    icon: Icons.send_outlined,
                    title: 'No referrals sent yet',
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchSentReferrals,
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
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ReferralCard(referral: controller.referrals[index]);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
        ),
      );
    });
  }
}
