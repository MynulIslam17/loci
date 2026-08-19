import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// A sticky bottom action bar with platform-native styling:
/// - **iOS:** Frosted glass [BackdropFilter] with subtle top hairline border.
/// - **Android:** Material 3 elevated container with soft ambient shadow.
class PersistentActionBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PersistentActionBar({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isIOS = context.isCupertino;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = SafeArea(
      top: false,
      child: Padding(
        padding: padding ??
            const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: child,
      ),
    );

    if (isIOS) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surface.withValues(alpha: 0.82)
                  : colors.surface.withValues(alpha: 0.86),
              border: Border(
                top: BorderSide(
                  color: colors.outlineVariant.withValues(
                    alpha: isDark ? 0.25 : 0.35,
                  ),
                  width: 0.5,
                ),
              ),
            ),
            child: content,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(
              alpha: isDark ? 0.30 : 0.45,
            ),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : colors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: content,
    );
  }
}
