import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/presentation/pages/home/widgets/user_post_header.dart';
import 'package:loci/presentation/pages/home/widgets/post_interaction_bar.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

import '../../../../data/models/community/announcement_model.dart';

class CommunityPollCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const CommunityPollCard({
    super.key,
    required this.announcement,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.colorScheme;
    final options = announcement.pollOptions ?? [];
    final totalVotes = announcement.totalVotes ?? 0;

    return Card(
      color: theme.surfaceContainer,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- HEADER -----
            _CommunityPollHeader(announcement: announcement),
            const SizedBox(height: 16),

            // ----- POLL QUESTION -----
            Text(
              announcement.pollQuestion ?? "",
              style: AppTextStyle.textMd(weight: FontWeight.w600),
            ),
            const SizedBox(height: 4),

            // ----- ENDS AT -----
            if (announcement.endsAt != null)
              Text(
                "Ends ${formatDateTime(announcement.endsAt!)}",
                style: AppTextStyle.textXs(
                  color: theme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 16),

            // ----- POLL OPTIONS -----
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = options[index];
                final percent = totalVotes > 0
                    ? (option.voteCount / totalVotes).clamp(0.0, 1.0)
                    : 0.0;
                final percentText =
                    "${(percent * 100).toStringAsFixed(0)}%";

                return _PollOptionBar(
                  option: option,
                  percent: percent,
                  trailingText: percentText,
                );
              },
            ),
            const SizedBox(height: 4),

            // ----- TOTAL VOTES -----
            Text(
              "$totalVotes votes",
              style: AppTextStyle.textXs(color: theme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            // ----- INTERACTION BAR -----
            PostInteractionBar(
              likes: (announcement.likeCount ?? 0).toString(),
              comments: (announcement.commentCount ?? 0).toString(),
              onLikeTap: onLikeTap,
              onCommentTap: onCommentTap,
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------
// HEADER — network image support
// -------------------------------------------------
class _CommunityPollHeader extends StatelessWidget {
  final AnnouncementModel announcement;

  const _CommunityPollHeader({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final theme = context.colorScheme;
    final business = announcement.business;

    return Row(
      children: [
        CustomCachedImage(
          width: 44,
          height: 44,
          isCircle: true,
          imageUrl: business?.logo ?? "",
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                business?.name ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.textMd(
                  weight: FontWeight.w600,
                  color: theme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatDateTime(announcement.createdAt),
                style: AppTextStyle.textXs(
                  color: theme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------
// POLL OPTION BAR — network image + progress
// -------------------------------------------------
class _PollOptionBar extends StatelessWidget {
  final PollOption option;
  final double percent;
  final String trailingText;

  const _PollOptionBar({
    required this.option,
    required this.percent,
    required this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Option image
        CustomCachedImage(
          width: 42,
          height: 42,
          isCircle: true,
          imageUrl: option.image ?? "",
        ),
        const SizedBox(width: 10),

        // Title + progress bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                option.text,
                style: AppTextStyle.textMd(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              LinearPercentIndicator(
                lineHeight: 10.0,
                percent: percent,
                backgroundColor: AppColors.base200,
                progressColor: AppColors.primaryG500,
                barRadius: const Radius.circular(10),
                animation: true,
                animationDuration: 800,
                padding: EdgeInsets.zero,
                trailing: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    trailingText,
                    style: AppTextStyle.textSm(
                      weight: FontWeight.w600,
                      color: AppColors.primaryG500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}