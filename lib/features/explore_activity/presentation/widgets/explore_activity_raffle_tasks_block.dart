import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_button.dart';

/// Entry requirements list + add button (create & edit raffle).
class ExploreActivityRaffleTasksBlock extends StatelessWidget {
  const ExploreActivityRaffleTasksBlock({
    super.key,
    required this.taskCards,
    required this.onAddRequirement,
    this.showHeader = true,
  });

  final List<Widget> taskCards;
  final VoidCallback onAddRequirement;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Text(
            'Entry requirements',
            style: AppTextStyle.textMd(
              weight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tasks participants must complete to enter',
            style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
        ],
        if (taskCards.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: taskCards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) => taskCards[index],
          ),
        if (taskCards.isNotEmpty) const SizedBox(height: 12),
        CustomButton(
          backgroundColor: colorScheme.surface,
          side: BorderSide(color: colorScheme.primary),
          onPressed: onAddRequirement,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Add requirement',
                style: AppTextStyle.textMd(
                  color: colorScheme.primary,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
