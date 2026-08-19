import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Shows a non-dismissible, platform-native loading overlay HUD.
///
/// * **iOS:** Frosted glass Cupertino HUD with [CupertinoActivityIndicator].
/// * **Android:** Material 3 elevated card with [CircularProgressIndicator] and subtitle.
///
/// Call [hideLoadingDialog] to dismiss when work completes.
void showLoadingDialog({
  BuildContext? context,
  String message = 'Signing out...',
}) {
  final targetContext = context ?? Get.overlayContext ?? Get.context;
  if (targetContext == null) return;

  final isCupertino = targetContext.isCupertino;

  if (isCupertino) {
    showCupertinoDialog<void>(
      context: targetContext,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: 140,
                height: 120,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.70)
                      : Colors.white.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(dialogContext).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CupertinoActivityIndicator(radius: 14),
                    const SizedBox(height: 14),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                        color: Theme.of(dialogContext).brightness ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  } else {
    final colors = targetContext.colorScheme;
    final isDark = Theme.of(targetContext).brightness == Brightness.dark;

    showDialog<void>(
      context: targetContext,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: colors.outlineVariant.withValues(
                alpha: isDark ? 0.3 : 0.45,
              ),
              width: 0.8,
            ),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.2,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: AppTextStyle.textMd(
                          color: colors.onSurface,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Please wait...',
                        style: AppTextStyle.textXs(
                          color: colors.onSurfaceVariant,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dismisses the loading dialog if one is currently open.
void hideLoadingDialog({BuildContext? context}) {
  final targetContext = context ?? Get.overlayContext ?? Get.context;
  if (targetContext != null && Navigator.canPop(targetContext)) {
    Navigator.of(targetContext, rootNavigator: true).pop();
  }
}
