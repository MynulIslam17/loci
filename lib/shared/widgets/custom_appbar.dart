import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle,
    this.bottom,
    this.elevation,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isIOS = context.isCupertino;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: AppTextStyle.textLg(
          color: colors.onSurface,
          weight: FontWeight.w700,
        ),
      ),
      centerTitle: centerTitle ?? isIOS,
      leading: leading,
      actions: actions,
      bottom: bottom,
      elevation: elevation ?? 0,
      scrolledUnderElevation: isIOS ? 0 : 2.5,
      backgroundColor: isIOS
          ? (isDark
              ? colors.surface.withValues(alpha: 0.82)
              : colors.surface.withValues(alpha: 0.85))
          : null,
      flexibleSpace: isIOS
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: colors.outlineVariant.withValues(
                          alpha: isDark ? 0.2 : 0.35,
                        ),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

