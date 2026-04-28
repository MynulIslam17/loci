import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';
import '../../../widgets/custom_image_container.dart';

Widget buildBusinessActivityCard({
  required BuildContext context,
  required String businessName,
  required String category,
  required String lastVisited,
  required VoidCallback onMenuTap,
  String? imageUrl,
}) {
  final colorScheme = context.colorScheme;

  return Card(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: colorScheme.surfaceContainerHigh,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          // --- Business Logo ---
          CustomCachedImage(
            width: 52,
            height: 52,
            imageUrl: imageUrl ?? "",
            isCircle: true,
          ),
          const SizedBox(width: 14),

          // --- Details ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  style: AppTextStyle.textSm(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  category,
                  style: AppTextStyle.textXs(
                    color: colorScheme.primary,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                        Icons.history,
                        size: 12,
                        color: colorScheme.onSurfaceVariant
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Visited $lastVisited",
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Three Dot Menu ---
          IconButton(
            onPressed: onMenuTap,
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    ),
  );
}