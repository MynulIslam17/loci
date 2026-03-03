import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import '../../../core/constants/app_text_style.dart';

class EventEditCard extends StatelessWidget {
  final String title;
  final String description;
  final String dateTime;
  final String location;
  final String attendance;
  final String imageUrl;
  final String? organizerName;
  final VoidCallback? onEditInfo;
  final VoidCallback? onViewDetails;

  const EventEditCard({
    super.key,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.attendance,
    required this.imageUrl,
    this.organizerName = "Crawl Events Co.",
    this.onEditInfo,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCachedImage(
            imageUrl: imageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            customBorderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.textMd(
                    weight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // Meta Info
                _buildMetaItem(context, Icons.calendar_today_outlined, dateTime),
                const SizedBox(height: 8),
                _buildMetaItem(context, Icons.location_on_outlined, location),
                const SizedBox(height: 8),
                _buildMetaItem(context, Icons.people_outline, attendance),

                // Organizer Name moved inside
                if (organizerName != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    "by $organizerName",
                    style: AppTextStyle.textXs(
                      weight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Management Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEditInfo,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: colorScheme.onSurface,
                        ),
                        label: Text(
                          "Edit Info",
                          style: AppTextStyle.textSm(
                            weight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onViewDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "View Details",
                              style: AppTextStyle.textSm(
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(BuildContext context, IconData icon, String text) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyle.textXs(
            color: colorScheme.onSurfaceVariant,
            weight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}