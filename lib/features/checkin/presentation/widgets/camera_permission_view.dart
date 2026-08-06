import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_button.dart';

/// Shown on the scan tab when camera access has not been granted. Adapts its
/// call-to-action depending on whether the user can still be re-prompted or
/// must enable the permission from system settings.
class CameraPermissionView extends StatelessWidget {
  const CameraPermissionView({
    super.key,
    required this.permanentlyDenied,
    required this.onAllow,
    required this.onOpenSettings,
    this.onEnterManually,
    this.title,
    this.description,
    this.manualActionLabel,
  });

  /// When true, the OS won't show the prompt again — send the user to settings.
  final bool permanentlyDenied;
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;

  /// Optional shortcut to the manual-code tab.
  final VoidCallback? onEnterManually;
  final String? title;
  final String? description;
  final String? manualActionLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.no_photography_outlined,
                size: 44,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Camera access needed',
              textAlign: TextAlign.center,
              style: AppTextStyle.textLg(
                color: colorScheme.onSurface,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description ??
                  (permanentlyDenied
                      ? 'Enable camera access in Settings to scan QR codes, or enter the code manually.'
                      : 'We need your camera to scan the check-in QR code. You can also enter the code manually.'),
              textAlign: TextAlign.center,
              style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: permanentlyDenied ? 'Open Settings' : 'Allow camera',
                onPressed: permanentlyDenied ? onOpenSettings : onAllow,
              ),
            ),
            if (onEnterManually != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onEnterManually,
                child: Text(
                  manualActionLabel ?? 'Enter code manually',
                  style: AppTextStyle.textSm(color: colorScheme.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
