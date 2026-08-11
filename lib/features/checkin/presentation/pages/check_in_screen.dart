import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/checkin/presentation/controllers/check_in_controller.dart';
import 'package:loci/features/checkin/presentation/widgets/check_in_manual_tab.dart';
import 'package:loci/features/checkin/presentation/widgets/check_in_scan_tab.dart';
import 'package:loci/features/checkin/presentation/widgets/check_in_tab_bar.dart';

/// Clean presentation screen for Check-In feature.
/// Follows UI → Controller → Service → Repository → API architecture.
class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckInController>();

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(title: const Text('Check In'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              children: const [
                CheckInScanTab(),
                CheckInManualTab(),
              ],
            ),
          ),
          const CheckInTabBar(),
        ],
      ),
    );
  }
}
