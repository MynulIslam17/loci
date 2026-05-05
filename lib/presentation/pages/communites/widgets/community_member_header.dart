import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/routes/app_routes.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';

class CommunityMemberHeader extends StatelessWidget {
  const CommunityMemberHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

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
                            Text(
                              "480K",
                              style: AppTextStyle.textSm(
                                weight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Member",
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
                  onTap: () {},
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
      ],
    );
  }
}