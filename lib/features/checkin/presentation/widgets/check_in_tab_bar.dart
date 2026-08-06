import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/checkin/presentation/controllers/check_in_controller.dart';

/// Bottom tab selector for Check-In feature (Scan QR vs Manual).
class CheckInTabBar extends StatelessWidget {
  const CheckInTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckInController>();
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            _tabItem(
              context,
              controller,
              CheckInTab.scan,
              'Scan QR',
              Icons.qr_code_scanner,
            ),
            _tabItem(
              context,
              controller,
              CheckInTab.manual,
              'Manual',
              Icons.keyboard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(
    BuildContext context,
    CheckInController controller,
    CheckInTab tab,
    String label,
    IconData icon,
  ) {
    final colorScheme = context.colorScheme;
    final selected = controller.activeTab.value == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectTab(tab),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyle.textSm(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  weight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
