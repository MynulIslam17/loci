import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/action_type.dart';

import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/features/network/presentation/controllers/received_referrals_controller.dart';
import 'package:loci/features/network/presentation/controllers/respond_referral_controller.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/features/network/presentation/widgets/referral_invitation_card.dart';
import 'package:loci/features/network/presentation/widgets/referral_shimmer.dart';

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
      if (controller.isLoading) {
        return const ReferralShimmer();
      }

      if (controller.errorMessage != null && controller.referrals.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.fetchReceivedReferrals,
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
        return RefreshIndicator(
          onRefresh: controller.fetchReceivedReferrals,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: const Center(
                  child: EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No referrals received yet',
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchReceivedReferrals,
        child: ListView.separated(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount:
              controller.referrals.length + (controller.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.referrals.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final referral = controller.referrals[index];
            final respondController = Get.find<RespondReferralController>();
            return Obx(() {
              final responding = respondController.isResponding(referral.id);
              return ReferralInvitationCard(
                status: referral.status,
                recipientName: referral.recipient.fullName,
                recipientEmail: referral.recipient.email,
                referredByName: referral.referredBy.fullName,
                referredByEmail: referral.referredBy.email,
                message: referral.message,
                date: DateParserHelper.eventDateTime(
                  DateParserHelper.parseDate(referral.createdAt)?.toLocal(),
                ),
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
          separatorBuilder: (_, __) => const SizedBox(height: 15),
        ),
      );
    });
  }
}
