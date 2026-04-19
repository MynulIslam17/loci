import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

import '../../../../core/constants/app_text_style.dart';


class RaffleEditCard extends StatelessWidget {
  final String title;
  final String description;
  final String endDate;
  final String prizeText;
  final String imageUrl;
  final String organizerName;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const RaffleEditCard({
    super.key,
    required this.title,
    required this.description,
    required this.endDate,
    required this.prizeText,
    required this.imageUrl,
    required this.organizerName,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCachedImage(
            imageUrl: imageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            customBorderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.textLg(
                    weight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.textSm(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Prize Value Badge -
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    // Using a light teal for light mode, or surfaceVariant for dark mode
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFFE0F2F1)
                        : colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    prizeText,
                    style: AppTextStyle.textMd(
                      weight: FontWeight.w700,
                      color: const Color(0xFF26A69A), // Brand Teal
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Row
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 16,
                        color: const Color(0xFF26A69A)),
                    const SizedBox(width: 8),
                    Text(
                      "Ends $endDate",
                      style: AppTextStyle.textSm(
                        weight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Buttons Section
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                        ),
                        child: OutlinedButton(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colorScheme.surface,
                            side: BorderSide(color: colorScheme.outlineVariant),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_outlined, size: 20, color: colorScheme.onSurface),
                              const SizedBox(width: 8),
                              Text("Edit Info",
                                  style: AppTextStyle.textSm(weight: FontWeight.w600, color: colorScheme.onSurface)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onView,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64BDB4), // Brand Teal from image
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("View Details",
                                style: AppTextStyle.textSm(weight: FontWeight.w600, color: Colors.white)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "by $organizerName",
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}