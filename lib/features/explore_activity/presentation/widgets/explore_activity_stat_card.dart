import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class ExploreActivityStatCard extends StatelessWidget {
  const ExploreActivityStatCard({
    super.key,
    required this.icon,
    required this.count,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24, color: colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(
                    count,
                    style: AppTextStyle.textLg(
                      weight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyle.textXs(
                  color: colorScheme.onSurface,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
