import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_logo_avatar.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// A claimed-business card that expands on tap to reveal details and a
/// "view page" action. Expansion is controlled by the parent via [isExpanded].
class ExpandableBusinessCard extends StatelessWidget {
  final String businessName;
  final String? category;
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
    this.category,
    required this.description,
    required this.imagePath,
    required this.isExpanded,
    required this.onTap,
    required this.onViewPage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final categoryLabel = category?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpanded
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.outline,
              width: isExpanded ? 1.5 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      BusinessLogoAvatar(
                        logo: imagePath.isEmpty ? null : imagePath,
                        name: businessName,
                        size: 52,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              businessName,
                              style: AppTextStyle.textSm(
                                weight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (categoryLabel != null &&
                                categoryLabel.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                categoryLabel,
                                style: AppTextStyle.textXs(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: 1,
                        thickness: 0.6,
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      _ExpandedBanner(logo: imagePath),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (description.trim().isNotEmpty) ...[
                              Text(
                                description,
                                style: AppTextStyle.textXs(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
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
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedBanner extends StatelessWidget {
  final String logo;

  const _ExpandedBanner({required this.logo});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    if (logo.trim().isEmpty) {
      return Container(
        width: double.infinity,
        height: 160,
        color: scheme.primary.withValues(alpha: 0.06),
        alignment: Alignment.center,
        child: Icon(
          Icons.storefront_rounded,
          size: 48,
          color: scheme.primary.withValues(alpha: 0.5),
        ),
      );
    }

    return CustomCachedImage(
      width: double.infinity,
      height: 160,
      imageUrl: logo,
      fit: BoxFit.cover,
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
