import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Loading list for meeting and referral tabs.
class NetworkListShimmer extends StatelessWidget {
  const NetworkListShimmer({super.key, this.showMeetingDetails = false});

  final bool showMeetingDetails;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) =>
          _CardShimmer(showMeetingDetails: showMeetingDetails),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }
}

class _CardShimmer extends StatelessWidget {
  const _CardShimmer({required this.showMeetingDetails});

  final bool showMeetingDetails;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppSkeleton.box(width: 72, height: 22, radius: 6),
              AppSkeleton.box(width: 80, height: 10, radius: 4),
            ],
          ),
          const SizedBox(height: 12),
          const _PersonShimmer(),
          const SizedBox(height: 6),
          AppSkeleton.box(width: 14, height: 14, radius: 4),
          const SizedBox(height: 6),
          const _PersonShimmer(),
          if (showMeetingDetails) ...[
            const SizedBox(height: 10),
            AppSkeleton.box(width: 160, height: 10, radius: 4),
            const SizedBox(height: 6),
            AppSkeleton.box(width: 100, height: 10, radius: 4),
          ],
          const SizedBox(height: 12),
          AppSkeleton.box(
            height: showMeetingDetails ? 32 : 40,
            width: double.infinity,
            radius: 8,
          ),
        ],
      ),
    );
  }
}

class _PersonShimmer extends StatelessWidget {
  const _PersonShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton.box(width: 70, height: 10, radius: 4),
        const SizedBox(height: 6),
        AppSkeleton.box(width: 120, height: 12, radius: 4),
        const SizedBox(height: 6),
        AppSkeleton.box(width: 160, height: 10, radius: 4),
      ],
    );
  }
}
