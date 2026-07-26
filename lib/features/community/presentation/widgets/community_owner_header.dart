import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/community/presentation/controllers/my_community_controller.dart';

import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/qrcode_maker.dart';

class CommunityOwnerHeader extends StatelessWidget {
  CommunityOwnerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final controller = Get.find<MyCommunityController>();

    return Obx(() {
      //  SHOW LOADER FIRST
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final community = controller.community.value;

      return Column(
        children: [
          Row(
            children: [
              // ---- Member Card ----
              Expanded(
                child: Card(
                  elevation: 1,
                  color: colorScheme.surfaceContainerHigh,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.communityMemberScreen,
                        arguments: {'communityId': community?.id},
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.group,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 10),

                              //  DYNAMIC VALUE
                              Text(
                                "${community?.memberCount ?? 0}",
                                style: AppTextStyle.textSm(
                                  weight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Members",
                            style: AppTextStyle.textMd(
                              weight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // ---- QR Card ----
              Expanded(
                child: Card(
                  elevation: 1,
                  color: colorScheme.surfaceContainerHigh,
                  child: InkWell(
                    onTap: () {
                      // TODO: show QR
                      CustomQrCode.show(
                        context,
                        data: community?.qrCode ?? "",
                        title: community?.name ?? "",
                        subtitle:
                            "Scan this QR code to join ${community?.name ?? 'this community'}",
                        appName: "Loci",
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.qr_code,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Join QR code",
                            style: AppTextStyle.textSm(
                              weight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          CustomButton(
            onPressed: () {
              Get.toNamed(
                AppRoutes.createAnnouncement,
                arguments: {"communityId": community?.id},
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: colorScheme.onPrimary, size: 20),
                const SizedBox(width: 10),
                Text(
                  "Announcement",
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
