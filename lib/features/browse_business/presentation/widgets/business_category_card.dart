import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'business_category_ui_helper.dart';

/// A modern, professional, and clean card representing a business category in [BrowseScreen].
/// Centered icon squircle and typography for balanced, elegant UI across iOS & Android.
class BusinessCategoryCard extends StatelessWidget {
  final BusinessCategory category;
  final VoidCallback onTap;

  const BusinessCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final accent = BusinessCategoryUI.accentColor(category);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── 1. Centered Highlighted Icon Squircle ───────────────────
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.28),
                    width: 1.2,
                  ),
                ),
                child: SvgPicture.asset(
                  BusinessCategoryUI.icon(category),
                  colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                ),
              ),

              const SizedBox(height: 10),

              // ── 2. Centered Category Title ──────────────────────────────
              Text(
                BusinessCategoryUI.label(category),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.textSm(
                  weight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 3),

              // ── 3. Centered Subtitle / Hint ─────────────────────────────
              Text(
                'Explore places',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.textXs(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
