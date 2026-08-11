import 'package:flutter/material.dart';
import 'package:loci/core/enums/recent_activity.dart';
import 'package:loci/features/recent_activity/presentation/widgets/activity_card_shell.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Tab-specific shimmer placeholders for Recent Activity lists.
class RecentActivityShimmer {
  RecentActivityShimmer._();

  static Widget forType(
    RecentActivityType type, {
    required BuildContext context,
  }) {
    return switch (type) {
      RecentActivityType.questions => _list(context, _questionSkeleton),
      RecentActivityType.answered => _list(context, _answerSkeleton),
      RecentActivityType.reviews => _list(context, _reviewSkeleton),
      RecentActivityType.business => _list(context, _businessSkeleton),
    };
  }

  static Widget _list(
    BuildContext context,
    Widget Function(BuildContext context) builder,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 0),
      itemBuilder: (context, _) => builder(context),
    );
  }

  static Widget _questionSkeleton(BuildContext context) {
    return ActivityCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(width: 44, height: 44, radius: 22),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: SkeletonBox(width: 100, height: 14)),
                        SizedBox(width: 8),
                        SkeletonBox(width: 64, height: 22, radius: 11),
                      ],
                    ),
                    SizedBox(height: 8),
                    SkeletonBox(width: double.infinity, height: 12),
                    SizedBox(height: 6),
                    SkeletonBox(width: 180, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              SkeletonBox(width: 56, height: 28, radius: 14),
              SizedBox(width: 8),
              SkeletonBox(width: 56, height: 28, radius: 14),
              Spacer(),
              SkeletonBox(width: 80, height: 28, radius: 14),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _answerSkeleton(BuildContext context) {
    return ActivityCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              SkeletonBox(width: 88, height: 26, radius: 13),
              Spacer(),
              SkeletonBox(width: 96, height: 26, radius: 13),
            ],
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 36, height: 36, radius: 18),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 24, height: 10),
                    SizedBox(height: 4),
                    SkeletonBox(width: double.infinity, height: 14),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 72, radius: 12),
        ],
      ),
    );
  }

  static Widget _reviewSkeleton(BuildContext context) {
    return ActivityCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 48, height: 48, radius: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 140, height: 14),
                    SizedBox(height: 6),
                    SkeletonBox(width: 100, height: 12),
                  ],
                ),
              ),
              SkeletonBox(width: 52, height: 28, radius: 14),
            ],
          ),
          SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 64, radius: 12),
        ],
      ),
    );
  }

  static Widget _businessSkeleton(BuildContext context) {
    return ActivityCardShell(
      child: Row(
        children: const [
          SkeletonBox(width: 54, height: 54, radius: 27),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 14),
                SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonBox(width: 72, height: 24, radius: 12),
                    SizedBox(width: 6),
                    SkeletonBox(width: 120, height: 24, radius: 12),
                  ],
                ),
              ],
            ),
          ),
          SkeletonBox(width: 36, height: 36, radius: 18),
        ],
      ),
    );
  }
}
