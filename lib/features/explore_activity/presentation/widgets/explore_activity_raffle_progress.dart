import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/raffles/data/models/raffle_detail_model.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ExploreActivityRaffleProgress extends StatelessWidget {
  const ExploreActivityRaffleProgress({super.key, required this.tasks});

  final List<RaffleTaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final progressValue = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final remainingTasks = totalTasks - completedTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Completion',
              style: AppTextStyle.textSm(
                weight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${(progressValue * 100).toInt()}%',
              style: AppTextStyle.textSm(
                weight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: LinearPercentIndicator(
            lineHeight: 12,
            percent: progressValue.clamp(0.0, 1.0),
            backgroundColor: colorScheme.outline.withValues(alpha: 0.35),
            progressColor: colorScheme.primary,
            barRadius: const Radius.circular(10),
            animation: true,
            animationDuration: 800,
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completedTasks of $totalTasks tasks completed',
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),
            Text(
              '$remainingTasks remaining',
              style: AppTextStyle.textXs(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
