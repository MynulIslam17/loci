import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/presentation/controllers/community/my_community_controlle.dart';

import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';
import '../../../../routes/app_routes.dart';
import '../../../widgets/custom_button.dart';

class CommunityOwnerHeader extends StatelessWidget {
  CommunityOwnerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GetBuilder<MyCommunityController>(
      builder: (controller) {

        //  SHOW LOADER FIRST
        if (controller.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final community = controller.community;

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
                        Get.toNamed(AppRoutes.communityMemberScreen);
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
                Get.toNamed(AppRoutes.createAnnouncement);
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
      },
    );
  }
}