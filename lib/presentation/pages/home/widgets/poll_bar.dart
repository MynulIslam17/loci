import 'package:flutter/material.dart';
import 'package:loci/data/models/community/announcement_model.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class PollBar extends StatelessWidget {
  final String title;
  final double percent;     // 0.0 – 1.0 for the progress indicator
  final double percentage;  // 0 – 100 displayed as text
  final String? imagePath;  // option image shown on the left
  final List<Voter> voters;
  final Color? progressColor;

  const PollBar({
    super.key,
    required this.title,
    required this.percent,
    this.percentage = 0,
    this.imagePath,
    this.voters = const [],
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Option image on the left
        CustomCachedImage(
          width: 40,
          height: 40,
          isCircle: true,
          imageUrl: imagePath ?? '',
        ),
        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.textMd(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),

              // Progress bar + percentage
              Row(
                children: [
                  Expanded(
                    child: LinearPercentIndicator(
                      lineHeight: 10.0,
                      percent: percent.clamp(0.0, 1.0),
                      backgroundColor: AppColors.base200,
                      progressColor: progressColor ?? AppColors.primaryG500,
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
                      color: AppColors.primaryG500,
                    ),
                  ),
                ],
              ),

              // Voter avatar stack
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

// Exported so PollBottomSheet can reuse it
class VoterStack extends StatelessWidget {
  final List<Voter> voters;
  final double size;

  const VoterStack({super.key, required this.voters, this.size = 28});

  @override
  Widget build(BuildContext context) {
    if (voters.isEmpty) return const SizedBox.shrink();

    const maxShow = 3;
    const overlap = 10.0;

    final shown = voters.take(maxShow).toList();
    final extra = voters.length - maxShow;
    final stackWidth = shown.length * (size - overlap) + overlap +
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
