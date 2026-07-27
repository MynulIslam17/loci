import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class MyBusinessSectionHeader extends StatelessWidget {
  const MyBusinessSectionHeader({
    super.key,
    required this.title,
    this.showViewAll = false,
    this.onViewAllTap,
  });

  final String title;
  final bool showViewAll;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyle.textXl(
              color: colorScheme.primary,
              weight: FontWeight.w600,
            ),
          ),
          if (showViewAll)
            TextButton(
              onPressed: onViewAllTap,
              child: Text(
                'View all',
                style: AppTextStyle.textXs(color: colorScheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}
