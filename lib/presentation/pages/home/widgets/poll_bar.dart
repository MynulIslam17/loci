import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class PollBar extends StatelessWidget {
  final String title;
  final double percent; // Should be between 0.0 and 1.0
  final String imagePath;
  final Color? progressColor;
  final String? trailingText;

  const PollBar({
    super.key,
    required this.title,
    required this.percent,
    required this.imagePath,
    this.progressColor,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Voter/Option Image
        CircleAvatar(
          radius: 21,
          backgroundImage: AssetImage(imagePath),
          backgroundColor: AppColors.base200,
        ),

        const SizedBox(width: 10),

        // 2. Title and Progress Bar
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
              LinearPercentIndicator(
                lineHeight: 10.0,
                percent: percent,
                backgroundColor: AppColors.base200,
                // Defaults to your verified #32A69A if no color is passed
                progressColor: progressColor ?? AppColors.primaryG500,
                barRadius: const Radius.circular(10),
                animation: true,
                animationDuration: 1000,
                padding: EdgeInsets.zero,
                // This adds the percentage text at the end of the bar
                trailing: trailingText != null
                    ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    trailingText!,
                    style: AppTextStyle.textSm(
                      weight: FontWeight.w600,
                      color: AppColors.primaryG500,
                    ),
                  ),
                )
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}