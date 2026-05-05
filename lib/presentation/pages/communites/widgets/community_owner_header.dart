import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/theme_extention.dart';

class CommunityOwnerHeader extends StatelessWidget {
  const CommunityOwnerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        // ---- Top Image Card ----
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Image.asset(
                "assets/images/location.png",
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Marland Clutch Centre",
                    style: AppTextStyle.textSm(
                      weight: FontWeight.bold,
                      color: Colors.white,
                    ).copyWith(
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          offset: const Offset(1, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

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
  }
}