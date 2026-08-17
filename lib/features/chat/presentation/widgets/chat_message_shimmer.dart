import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';

/// Shimmer skeleton loader mimicking chat message bubbles.
class ChatMessageShimmer extends StatelessWidget {
  const ChatMessageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: const [
        _ReceivedBubbleShimmer(width: 170, height: 42),
        SizedBox(height: 12),
        _ReceivedBubbleShimmer(width: 230, height: 56),
        SizedBox(height: 14),
        _SentBubbleShimmer(width: 190, height: 46),
        SizedBox(height: 12),
        _SentBubbleShimmer(width: 130, height: 38),
        SizedBox(height: 14),
        _ReceivedBubbleShimmer(width: 210, height: 50),
        SizedBox(height: 14),
        _SentBubbleShimmer(width: 240, height: 58),
        SizedBox(height: 12),
        _SentBubbleShimmer(width: 160, height: 40),
      ],
    );
  }
}

class _ReceivedBubbleShimmer extends StatelessWidget {
  const _ReceivedBubbleShimmer({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SkeletonBox(width: 28, height: 28, radius: 14),
        const SizedBox(width: 8),
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSkeleton.box(width: width * 0.75, height: 10, radius: 4),
              if (height > 44) ...[
                const SizedBox(height: 6),
                AppSkeleton.box(width: width * 0.5, height: 9, radius: 3),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SentBubbleShimmer extends StatelessWidget {
  const _SentBubbleShimmer({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSkeleton.box(width: width * 0.8, height: 10, radius: 4),
              if (height > 44) ...[
                const SizedBox(height: 6),
                AppSkeleton.box(width: width * 0.45, height: 9, radius: 3),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
