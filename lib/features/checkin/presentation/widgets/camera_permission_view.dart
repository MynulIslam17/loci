import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_button.dart';

/// Shown on the scan tab when camera access has not been granted.
///
/// Designed to stay visible *behind* the OS permission dialog — so the user
/// never stares at a bare spinner while the system prompt is up.
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
    this.isRequesting = false,
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

  /// True while the system permission dialog is open / request is in flight.
  final bool isRequesting;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CameraPreviewPlaceholder(
                colorScheme: colorScheme,
                isRequesting: isRequesting,
              ),
              const SizedBox(height: 28),
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
                    (isRequesting
                        ? 'Waiting for your response on the permission prompt…'
                        : permanentlyDenied
                        ? 'Enable camera access in Settings to scan QR codes, or enter the code manually.'
                        : 'Allow camera access to scan the check-in QR. You can also enter the code manually.'),
                textAlign: TextAlign.center,
                style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: permanentlyDenied
                      ? 'Open Settings'
                      : (isRequesting ? 'Waiting…' : 'Allow camera'),
                  onPressed: isRequesting
                      ? null
                      : (permanentlyDenied ? onOpenSettings : onAllow),
                ),
              ),
              if (onEnterManually != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isRequesting ? null : onEnterManually,
                  child: Text(
                    manualActionLabel ?? 'Enter code manually',
                    style: AppTextStyle.textSm(
                      color: isRequesting
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft scanner-frame silhouette so the screen still looks like check-in
/// while permission is pending — not an empty spinner.
class _CameraPreviewPlaceholder extends StatelessWidget {
  const _CameraPreviewPlaceholder({
    required this.colorScheme,
    required this.isRequesting,
  });

  final ColorScheme colorScheme;
  final bool isRequesting;

  @override
  Widget build(BuildContext context) {
    final side = (MediaQuery.sizeOf(context).width - 72).clamp(200.0, 280.0);

    return SizedBox(
      width: side,
      height: side,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.6),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 72,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
            ),
            Positioned(
              top: 18,
              left: 18,
              child: _Corner(color: colorScheme.primary),
            ),
            Positioned(
              top: 18,
              right: 18,
              child: Transform.flip(
                flipX: true,
                child: _Corner(color: colorScheme.primary),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 18,
              child: Transform.flip(
                flipY: true,
                child: _Corner(color: colorScheme.primary),
              ),
            ),
            Positioned(
              bottom: 18,
              right: 18,
              child: Transform.flip(
                flipX: true,
                flipY: true,
                child: _Corner(color: colorScheme.primary),
              ),
            ),
            if (isRequesting)
              Positioned(
                bottom: 28,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Requesting access',
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurface,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(painter: _CornerPainter(color)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color;
}
