import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// A claimed-business card that expands on tap to reveal details and a
/// "view page" action. Expansion is controlled by the parent via [isExpanded].
class ExpandableBusinessCard extends StatelessWidget {
  final String businessName;
  final String description;
  final String imagePath;
  final bool isExpanded;

  /// Toggle expansion (parent owns the expanded-index state).
  final VoidCallback onTap;

  /// Open the full business page.
  final VoidCallback onViewPage;

  const ExpandableBusinessCard({
    super.key,
    required this.businessName,
    required this.description,
    required this.imagePath,
    required this.isExpanded,
    required this.onTap,
    required this.onViewPage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          color: colorScheme.surfaceContainerHigh,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomCachedImage(
                    width: double.infinity,
                    height: 190,
                    imageUrl: imagePath,
                  ),
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          businessName,
                          style: AppTextStyle.textSm(
                            weight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: AppTextStyle.textXs(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ActionRow(
                          icon: Icons.visibility_outlined,
                          label: "View Your Business Page",
                          color: colorScheme.primary,
                          onTap: onViewPage,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyle.textSm(
                weight: FontWeight.w500,
              ).copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
