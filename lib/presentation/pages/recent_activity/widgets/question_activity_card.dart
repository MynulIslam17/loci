import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';
import '../../../widgets/custom_image_container.dart';

Widget buildQuestionActivityCard({
  required BuildContext context,
  required String name,
  required String question,
  required int likeCount,
  required int commentCount,
  String? imageUrl,
  String? category,
  String? date,
  String? time,
}) {
  final colorScheme = context.colorScheme;

  return Card(
    color: colorScheme.surfaceContainerHigh,
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- User/Question Image ---
              CustomCachedImage(
                width: 48,
                height: 48,
                imageUrl: imageUrl ?? "",
                isCircle: true,
              ),
              const SizedBox(width: 12),

              // --- Question Content ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: AppTextStyle.textSm(
                            color: colorScheme.onSurface,
                            weight: FontWeight.w700,
                          ),
                        ),
                        // Small Badge for context
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category ?? "Question",
                            style: AppTextStyle.textXs(
                              color: colorScheme.onPrimaryContainer,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      question,
                      style: AppTextStyle.textSm(
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
          Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),
          const SizedBox(height: 8),

          // --- Interaction Footer (Likes & Comments) ---
          Row(
            children: [
              _buildStatItem(
                context: context,
                icon: Icons.favorite_border,
                count: likeCount,
                iconColor: colorScheme.error, // Reddish for likes
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                context: context,
                icon: Icons.chat_bubble_outline,
                count: commentCount,
                iconColor: colorScheme.primary, // Primary for comments
              ),

              Spacer(),

              Text(date ?? "", style: AppTextStyle.textXs()),

            ],
          ),
        ],
      ),
    ),
  );
}

// Helper to build the small stat items
Widget _buildStatItem({
  required BuildContext context,
  required IconData icon,
  required int count,
  required Color iconColor,
}) {
  final colorScheme = context.colorScheme;

  return Row(
    children: [
      Icon(icon, size: 16, color: iconColor.withOpacity(0.8)),
      const SizedBox(width: 4),
      Text(
        count.toString(),
        style: AppTextStyle.textXs(
          color: colorScheme.onSurfaceVariant,
          weight: FontWeight.w500,
        ),
      ),
    ],
  );
}