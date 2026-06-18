import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/theme_extention.dart';
import '../../../../../core/utils/date_parser.dart';
import '../../../../controllers/network_dash/sent_referrals_controller.dart';
import '../../../../widgets/empty_state.dart';
import '../../widget/referral_card.dart';
import '../../widget/referral_shimmer.dart';

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
    final color = context.colorScheme;

    return GetBuilder<SentReferralsController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const ReferralShimmer();
        }

        if (controller.errorMessage != null && controller.referrals.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchSentReferrals,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Center(
                  child: Text(
                    controller.errorMessage!,
                    style: AppTextStyle.textSm(color: color.error),
                  ),
                ),
              ],
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
          child: ListView.separated(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: controller.referrals.length + (controller.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.referrals.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final r = controller.referrals[index];
              return ReferralCard(
                status: r.status,
                recipientName: r.recipient.fullName,
                recipientEmail: r.recipient.email,
                businessOwnerName: r.businessOwner.fullName,
                businessOwnerEmail: r.businessOwner.email,
                message: r.message,
                date: DateParserHelper.eventDateTime(
                  DateParserHelper.parseDate(r.createdAt)?.toLocal(),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 15),
          ),
        );
      },
    );
  }
}
