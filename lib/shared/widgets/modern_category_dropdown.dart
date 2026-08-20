import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/browse_business/presentation/widgets/business_category_ui_helper.dart';

/// A sleek, modern dropdown selector for [BusinessCategory].
///
/// Features:
/// - Pill/card container with subtle borders and smooth theme integration.
/// - Dynamic category SVG icon badge.
/// - Opens an elegant modal sheet with rich icon badges and checkmark states.
class ModernCategoryDropdown extends StatelessWidget {
  final BusinessCategory? selectedCategory;
  final ValueChanged<BusinessCategory?> onChanged;
  final bool includeAllOption;
  final String hintText;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final String? label;

  const ModernCategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    this.includeAllOption = false,
    this.hintText = 'Select Category',
    this.width,
    this.padding,
    this.label,
  });

  void _showCategoryPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    final colors = context.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                // ── Drag Handle ──
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Header Title ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        label ?? 'Filter by Category',
                        style: AppTextStyle.textLg(
                          weight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        color: colors.onSurfaceVariant,
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // ── Category List ──
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: (includeAllOption ? 1 : 0) +
                        BusinessCategory.values.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final isAll = includeAllOption && index == 0;
                      final category = isAll
                          ? null
                          : BusinessCategory
                              .values[index - (includeAllOption ? 1 : 0)];

                      final isSelected = isAll
                          ? selectedCategory == null
                          : selectedCategory == category;

                      final String itemLabel =
                          isAll ? 'All Categories' : category!.label;

                      return Material(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(ctx).pop();
                            onChanged(category);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Icon badge
                                Container(
                                  width: 38,
                                  height: 38,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colors.primary
                                        : colors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: isAll
                                      ? Icon(
                                          Icons.apps_rounded,
                                          size: 20,
                                          color: isSelected
                                              ? colors.onPrimary
                                              : colors.onSurfaceVariant,
                                        )
                                      : SvgPicture.asset(
                                          BusinessCategoryUI.icon(category!),
                                          colorFilter: ColorFilter.mode(
                                            isSelected
                                                ? colors.onPrimary
                                                : colors.onSurface,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 14),

                                // Label
                                Expanded(
                                  child: Text(
                                    itemLabel,
                                    style: AppTextStyle.textSm(
                                      weight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurface,
                                    ),
                                  ),
                                ),

                                // Checkmark
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: colors.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final currentCat = selectedCategory;

    final String displayLabel = currentCat != null
        ? currentCat.label
        : (includeAllOption ? 'All Categories' : hintText);

    return InkWell(
      onTap: () => _showCategoryPicker(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.35),
            width: 1.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Icon Badge
            Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: currentCat != null
                  ? SvgPicture.asset(
                      BusinessCategoryUI.icon(currentCat),
                      colorFilter: ColorFilter.mode(
                        colors.primary,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      Icons.apps_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
            ),
            const SizedBox(width: 10),

            // Category Label
            Flexible(
              child: Text(
                displayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.textSm(
                  weight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Dropdown Chevron
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
