import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/models/post_card_view_model.dart';
import 'package:loci/shared/widgets/business_avatar.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PollBar extends StatelessWidget {
  final String title;
  final double percent;
  final double percentage;
  final String? imagePath;
  final List<PostVoter> voters;
  final Color? progressColor;
  final bool isVoted;

  const PollBar({
    super.key,
    required this.title,
    required this.percent,
    this.percentage = 0,
    this.imagePath,
    this.voters = const [],
    this.progressColor,
    this.isVoted = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = progressColor ?? AppColors.primaryG500;
    final barColor = isVoted ? activeColor : activeColor.withOpacity(0.5);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BusinessAvatar(imageUrl: imagePath, size: 40),
        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.textMd(
                  color: isVoted
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                  weight: isVoted ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),

              Row(
                children: [
                  Expanded(
                    child: LinearPercentIndicator(
                      lineHeight: 10.0,
                      percent: percent.clamp(0.0, 1.0),
                      backgroundColor: AppColors.base700,
                      progressColor: barColor,
                      barRadius: const Radius.circular(10),
                      animation: true,
                      animationDuration: 1000,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: AppTextStyle.textSm(
                      weight: FontWeight.w600,
                      color: isVoted
                          ? context.colorScheme.primary
                          : AppColors.primaryG500,
                    ),
                  ),
                ],
              ),

              if (voters.isNotEmpty) ...[
                const SizedBox(height: 8),
                VoterStack(voters: voters),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class VoterStack extends StatelessWidget {
  final List<PostVoter> voters;
  final double size;

  const VoterStack({super.key, required this.voters, this.size = 28});

  @override
  Widget build(BuildContext context) {
    if (voters.isEmpty) return const SizedBox.shrink();

    const maxShow = 3;
    const overlap = 10.0;

    final shown = voters.take(maxShow).toList();
    final extra = voters.length - maxShow;
    final stackWidth =
        shown.length * (size - overlap) +
        overlap +
        (extra > 0 ? size - overlap : 0);

    return SizedBox(
      width: stackWidth,
      height: size,
      child: Stack(
        children: [
          ...shown.asMap().entries.map(
            (e) => Positioned(
              left: e.key * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CustomCachedImage(
                  width: size,
                  height: size,
                  isCircle: true,
                  imageUrl: e.value.avatar,
                ),
              ),
            ),
          ),
          if (extra > 0)
            Positioned(
              left: shown.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.surfaceVariant,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: AppTextStyle.textXs(
                      weight: FontWeight.w600,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
