import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/checkin/presentation/controllers/check_in_controller.dart';
import 'package:loci/features/checkin/presentation/widgets/camera_permission_view.dart';
import 'package:loci/features/checkin/presentation/widgets/scanner_overlay.dart';

/// Tab for QR scanner camera view in Check-In feature.
class CheckInScanTab extends StatelessWidget {
  const CheckInScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckInController>();

    return Obx(() {
      switch (controller.cameraPermission.value) {
        case CameraPermissionState.checking:
          // Brief first-frame only — usually replaced before the user notices.
          return CameraPermissionView(
            permanentlyDenied: false,
            isRequesting: true,
            onAllow: controller.requestCameraPermission,
            onOpenSettings: openAppSettings,
            onEnterManually: () => controller.selectTab(CheckInTab.manual),
          );
        case CameraPermissionState.denied:
        case CameraPermissionState.permanentlyDenied:
          return CameraPermissionView(
            permanentlyDenied: controller.cameraPermission.value ==
                CameraPermissionState.permanentlyDenied,
            isRequesting: controller.isRequestingCamera.value,
            onAllow: controller.requestCameraPermission,
            onOpenSettings: openAppSettings,
            onEnterManually: () => controller.selectTab(CheckInTab.manual),
          );
        case CameraPermissionState.granted:
          return _buildScanner(context, controller);
      }
    });
  }

  Widget _buildScanner(BuildContext context, CheckInController controller) {
    final colorScheme = context.colorScheme;
    final side = (MediaQuery.of(context).size.width - 72).clamp(220.0, 300.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Scan the QR code',
            style: AppTextStyle.textLg(
              color: colorScheme.onSurface,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Point your camera at the check-in QR code',
            textAlign: TextAlign.center,
            style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: side,
            height: side,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: controller.scannerController,
                    onDetect: (capture) {
                      final code =
                          capture.barcodes.firstOrNull?.rawValue ?? '';
                      controller.onQrDetected(code);
                    },
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.15)),
                  const ScannerOverlay(),
                  Obx(
                    () => controller.isProcessing.value
                        ? Container(
                            color: Colors.black54,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildTorchButton(context, controller),
        ],
      ),
    );
  }

  Widget _buildTorchButton(BuildContext context, CheckInController controller) {
    final colorScheme = context.colorScheme;
    return Obx(() {
      final on = controller.torchOn.value;
      return OutlinedButton.icon(
        onPressed: controller.toggleTorch,
        icon: Icon(on ? Icons.flash_on : Icons.flash_off, size: 20),
        label: Text(on ? 'Flash on' : 'Flash off'),
        style: OutlinedButton.styleFrom(
          foregroundColor: on ? colorScheme.primary : colorScheme.onSurface,
          side: BorderSide(
            color: on ? colorScheme.primary : colorScheme.outline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      );
    });
  }
}
