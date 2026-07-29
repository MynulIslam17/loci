import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/controllers/my_community_controller.dart';
import 'package:loci/features/community/presentation/widgets/community_owner_header_shimmer.dart';
import 'package:loci/features/community/presentation/widgets/community_ui_constants.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

class CommunityMemberHeader extends StatelessWidget {
  const CommunityMemberHeader({super.key, this.fallbackName});

  final String? fallbackName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final controller = Get.find<MyCommunityController>();

    return Obx(() {
      if (controller.isLoading.value && controller.community.value == null) {
        return const CommunityOwnerHeaderShimmer();
      }

      final community = controller.community.value;
      final businessName =
          community?.business.name.trim().isNotEmpty == true
          ? community!.business.name
          : (fallbackName?.trim().isNotEmpty == true
                ? fallbackName!.trim()
                : 'Community');
      final logo = community?.business.logo;
      final members = community?.memberCount ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.isRefreshing.value)
            LinearProgressIndicator(
              minHeight: 2,
              color: colors.primary,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(CommunityUi.cardRadius),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                CustomCachedImage(
                  imageUrl: logo ?? '',
                  width: 52,
                  height: 52,
                  isCircle: true,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.textMd(
                          weight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$members members',
                        style: AppTextStyle.textXs(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: CommunityUi.sectionSpacing),
        ],
      );
    });
  }
}
