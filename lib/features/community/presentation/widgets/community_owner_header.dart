import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/controllers/my_community_controller.dart';
import 'package:loci/features/community/presentation/widgets/community_header_action_card.dart';
import 'package:loci/features/community/presentation/widgets/community_owner_header_shimmer.dart';
import 'package:loci/features/community/presentation/widgets/community_ui_constants.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/qrcode_maker.dart';

class CommunityOwnerHeader extends StatelessWidget {
  const CommunityOwnerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final controller = Get.find<MyCommunityController>();

    return Obx(() {
      if (controller.isLoading.value && controller.community.value == null) {
        return const CommunityOwnerHeaderShimmer();
      }

      final community = controller.community.value;
      final communityId = community?.id ?? '';
      final communityName = community?.name ?? 'Community';
      final memberCount = '${community?.memberCount ?? 0}';

      return Column(
        children: [
          if (controller.isRefreshing.value)
            LinearProgressIndicator(
              minHeight: 2,
              color: colorScheme.primary,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          Row(
            children: [
              Expanded(
                child: CommunityHeaderActionCard(
                  icon: Icons.group_outlined,
                  label: 'Members',
                  value: memberCount,
                  onTap: communityId.isEmpty
                      ? null
                      : () => Get.toNamed(
                          AppRoutes.communityMemberScreen,
                          arguments: {'communityId': communityId},
                        ),
                ),
              ),
              const SizedBox(width: CommunityUi.sectionSpacing),
              Expanded(
                child: CommunityHeaderActionCard(
                  icon: Icons.qr_code_2_rounded,
                  label: 'Join QR code',
                  onTap: () {
                    CustomQrCode.show(
                      context,
                      data: community?.qrCode ?? '',
                      title: communityName,
                      subtitle:
                          'Scan this QR code to join $communityName',
                      appName: 'Loci',
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: CommunityUi.sectionSpacing),
          CustomButton(
            onPressed: communityId.isEmpty
                ? null
                : () => Get.toNamed(
                    AppRoutes.createAnnouncement,
                    arguments: {
                      'communityId': communityId,
                      'postAsBusiness': true,
                    },
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: colorScheme.onPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Create announcement',
                  style: AppTextStyle.textMd(
                    weight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
