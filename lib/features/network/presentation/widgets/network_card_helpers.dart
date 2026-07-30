import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Arrow divider between two people on a meeting/referral card.
class NetworkConnector extends StatelessWidget {
  const NetworkConnector({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 2),
          Icon(Icons.south, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: colors.outlineVariant.withValues(alpha: 0.7),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Optional quoted message at the bottom of a meeting/referral card.
class NetworkMessageBubble extends StatelessWidget {
  const NetworkMessageBubble({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote, size: 16, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              softWrap: true,
              style: AppTextStyle.textSm(
                color: colors.onSurfaceVariant,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
