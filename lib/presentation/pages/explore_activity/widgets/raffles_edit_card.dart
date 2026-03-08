import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

import '../../../../core/constants/app_text_style.dart';


class RaffleEditCard extends StatelessWidget {
  final String title;
  final String description;
  final String endDate;
  final String ticketPrice;
  final String totalTickets;
  final String imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const RaffleEditCard({
    super.key,
    required this.title,
    required this.description,
    required this.endDate,
    required this.ticketPrice,
    required this.totalTickets,
    required this.imageUrl,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetaItem(
                      context,
                      Icons.calendar_today_outlined,
                      endDate,
                    ),
                    _buildMetaItem(
                        context,
                        Icons.confirmation_number_outlined,
                        ticketPrice
                    ),
                    _buildMetaItem(
                        context,
                        Icons.group_outlined,
                        totalTickets
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
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
                        onPressed: onView,
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