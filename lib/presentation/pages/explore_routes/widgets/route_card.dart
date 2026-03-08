import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import '../../../../../core/constants/app_text_style.dart';
import '../../../widgets/custom_image_container.dart';


class RouteCard extends StatelessWidget {
  final String title;
  final String description;
  final String location;
  final String duration;
  final String difficulty;
  final String imageUrl;
  final VoidCallback? onTap;

  const RouteCard({
    super.key,
    required this.title,
    required this.description,
    required this.location,
    required this.duration,
    required this.difficulty,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: colorScheme.surfaceContainerHigh,
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            CustomCachedImage(
              imageUrl: imageUrl,
              height: 180,
              width: double.infinity,
              customBorderRadius:  BorderRadius.vertical(top: Radius.circular(12)),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.textMd(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        context,
                        Icons.location_on_outlined,
                        location,
                      ),
                      _buildInfoItem(
                        context,
                        Icons.access_time,
                        duration,
                      ),
                      _buildInfoItem(
                        context,
                        Icons.explore_outlined,
                        difficulty,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the small info items (Location, Duration, etc.)
  Widget _buildInfoItem(BuildContext context, IconData icon, String label) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyle.textXs(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}