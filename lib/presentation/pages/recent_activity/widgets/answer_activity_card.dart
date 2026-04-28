import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';
import '../../../widgets/custom_image_container.dart';

Widget buildAnswerActivityCard({
  required BuildContext context,
  required String question,
  required String answer,
  required String timestamp,
  String? imageUrl,
}) {
  final colorScheme = context.colorScheme;

  return Card(
    elevation: 2,
    color: colorScheme.surfaceContainerHigh,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Image Section
              CustomCachedImage(
                imageUrl: imageUrl ?? "",
                width: 60,
                height: 60,
                isCircle: true,
              ),
              const SizedBox(width: 12),

              // --- Text Content ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question,
                      style: AppTextStyle.textSm(
                        color: colorScheme.onSurface,
                        weight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      answer,
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                        weight: FontWeight.w400,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 8),

          // --- Footer / Timestamp ---
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              Icon(
                Icons.schedule,
                size: 14,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                timestamp,
                style: AppTextStyle.textXs(
                  color: colorScheme.onSurfaceVariant,
                  weight: FontWeight.w500,
                ),
              ),

            ],
          ),
        ],
      ),
    ),
  );
}