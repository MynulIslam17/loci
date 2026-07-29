import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/widgets/community_ui_constants.dart';

class CommunityHeaderActionCard extends StatelessWidget {
  const CommunityHeaderActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CommunityUi.headerActionRadius),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CommunityUi.headerActionRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconCircle(icon: icon, colors: colors),
                  if (value != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      value!,
                      style: AppTextStyle.textSm(
                        weight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyle.textSm(
                  weight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.colors});

  final IconData icon;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: colors.onSurfaceVariant),
    );
  }
}
