import 'package:flutter/material.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';


class EmptyCommunityState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final double iconSize;

  const EmptyCommunityState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyle.textMd(
                color: colorScheme.onSurfaceVariant,
                weight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: AppTextStyle.textSm(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}