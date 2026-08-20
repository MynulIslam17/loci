import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';

import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/browse_business/presentation/controllers/save_business_controller.dart';
import 'package:loci/shared/widgets/confirm_dialog.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'business_logo_avatar.dart';

class BrowseBusinessCard extends StatelessWidget {
  final BrowseBusinessModel item;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onView;

  const BrowseBusinessCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onTap,
    required this.onAdd,
    required this.onView,
  });

  Future<void> _confirmUnsave(
    BuildContext context,
    SaveBusinessController ctrl,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove from list?',
      message:
          'Do you want to remove "${item.name}" from your saved businesses?',
      confirmText: 'Remove',
      icon: Icons.bookmark_remove_outlined,
      isDestructive: true,
    );
    if (confirmed) {
      await ctrl.unsaveBusiness(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? context.colorScheme.primary.withValues(alpha: 0.6)
                : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isExpanded ? 1.2 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isExpanded ? 0.04 : 0.02),
              blurRadius: isExpanded ? 10 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    BusinessLogoAvatar(
                      logo: item.logo,
                      name: item.name,
                      size: 50,
                      borderRadius: 12,
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppTextStyle.textSm(
                              weight: FontWeight.w700,
                              color: context.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.category,
                            style: AppTextStyle.textXs(
                              color: context.colorScheme.onSurfaceVariant,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: AppTextStyle.textXs(
                              color: const Color(0xFFD97706),
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // ================= EXPANDED =================
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
                      color: context.colorScheme.outline.withValues(alpha: 0.2),
                    ),

                    _ExpandedBanner(logo: item.logo),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: AppTextStyle.textXs(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.textXs(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              //-----save business----
                              Obx(() {
                                final ctrl = Get.find<SaveBusinessController>();
                                final loading = ctrl.isLoading(item.id);
                                final saved = ctrl.isSaved(item.id, item.isSaved);

                                if (loading) {
                                  return OutlinedButton.icon(
                                    onPressed: null,
                                    icon: const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    label: const Text("Please wait..."),
                                  );
                                }

                                if (saved) {
                                  return OutlinedButton.icon(
                                    onPressed: () =>
                                        _confirmUnsave(context, ctrl),
                                    icon: const Icon(Icons.check),
                                    label: const Text("Saved"),
                                  );
                                }

                                return OutlinedButton.icon(
                                  onPressed: onAdd,
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add to list"),
                                );
                              }),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: onView,
                                  icon: const Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 16,
                                  ),
                                  label: const Text("View page"),
                                ),
                              ),
                            ],
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
    );
  }
}

/// Full-width banner shown in the expanded card. Falls back to a neutral
/// placeholder instead of a broken-image box when the business has no logo.
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
