import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class SubscriptionFeatureItem extends StatelessWidget {
  const SubscriptionFeatureItem({
    super.key,
    required this.label,
    this.included = true,
    this.compact = false,
    this.accentColor,
  });

  final String label;
  final bool included;
  final bool compact;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;
    final Color accent = included
        ? (accentColor ?? const Color(0xFF16A36A))
        : colors.outline;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 4 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: compact ? 19 : 22,
            height: compact ? 19 : 22,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              included ? Icons.check_rounded : Icons.close_rounded,
              size: compact ? 13 : 15,
              color: accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyle.textXs(
                color: included ? colors.onSurface : colors.onSurfaceVariant,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
