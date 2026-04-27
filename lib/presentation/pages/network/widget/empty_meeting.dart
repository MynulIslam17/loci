import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class EmptyMeetingWidget extends StatelessWidget {
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyMeetingWidget({
    super.key,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),

            const SizedBox(height: 16),

            Text(
              "No Meetings Yet",
              style: AppTextStyle.textLg(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "You don’t have any meetings scheduled for this day.",
              textAlign: TextAlign.center,
              style: AppTextStyle.textSm(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            if (onActionPressed != null)
              InkWell(
                onTap: onActionPressed,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    actionText ?? "Schedule New",
                    style: AppTextStyle.textXs(
                      color: colorScheme.primary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}