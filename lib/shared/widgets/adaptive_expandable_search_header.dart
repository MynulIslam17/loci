import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Cross-platform adaptive expandable search header.
///
/// - **iOS**: Apple Music / App Store transparent frosted glass search bar
///   with native Cupertino blur, typography, and "Cancel" action.
/// - **Android**: Material 3 styled surface container with squircle curves
///   and ripple interactions.
///
/// In collapsed state: Displays [title] and [subtitle] on the left, with an
/// adaptive circular search button in the top-right corner.
///
/// In expanded state: Smoothly animates into a full-width search bar with
/// autofocus, live debounced filtering, and a cancel action.
class AdaptiveExpandableSearchHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget? trailing;
  final TextEditingController searchController;
  final FocusNode? searchFocus;
  final String hintText;
  final bool isExpanded;
  final ValueChanged<bool> onToggleExpand;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onClear;
  final double height;
  final EdgeInsetsGeometry padding;

  const AdaptiveExpandableSearchHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.titleWidget,
    this.trailing,
    required this.searchController,
    this.searchFocus,
    this.hintText = "Search...",
    required this.isExpanded,
    required this.onToggleExpand,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClear,
    this.height = 70.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colorScheme;

    return Container(
      height: height,
      padding: padding,
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: isExpanded
            ? (isIOS
                ? _buildIOSGlassSearchBar(context, colors, isDark)
                : _buildAndroidSearchBar(context, colors, isDark))
            : _buildCollapsedHeader(context, colors, isDark, isIOS),
      ),
    );
  }

  // ── Collapsed State (Title + Corner 🔍 Button) ────────────────────────────

  Widget _buildCollapsedHeader(
    BuildContext context,
    ColorScheme colors,
    bool isDark,
    bool isIOS,
  ) {
    return Row(
      key: const ValueKey('collapsed_header'),
      children: [
        Expanded(
          child: titleWidget ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.textXl(
                      color: colors.onSurface,
                      weight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyle.textXs(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
        const SizedBox(width: 8),
        _buildCornerSearchButton(context, colors, isDark, isIOS),
      ],
    );
  }

  Widget _buildCornerSearchButton(
    BuildContext context,
    ColorScheme colors,
    bool isDark,
    bool isIOS,
  ) {
    void handleTap() {
      HapticFeedback.lightImpact();
      onToggleExpand(true);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (searchFocus != null && searchFocus!.canRequestFocus) {
          searchFocus!.requestFocus();
        }
      });
    }

    if (isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        onPressed: handleTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.06),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.08),
              width: 0.8,
            ),
          ),
          child: Icon(
            CupertinoIcons.search,
            size: 20,
            color: colors.primary,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: handleTap,
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(
              alpha: isDark ? 0.6 : 0.7,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.outlineVariant.withValues(
                alpha: isDark ? 0.4 : 0.3,
              ),
              width: 0.8,
            ),
          ),
          child: Icon(
            Icons.search_rounded,
            size: 22,
            color: colors.primary,
          ),
        ),
      ),
    );
  }

  // ── iOS Apple Music / App Store Frosted Glass Search Bar ──────────────────

  Widget _buildIOSGlassSearchBar(
    BuildContext context,
    ColorScheme colors,
    bool isDark,
  ) {
    return Row(
      key: const ValueKey('ios_glass_search_bar'),
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  CupertinoIcons.search,
                  size: 18,
                  color: isDark
                      ? CupertinoColors.systemGrey.color
                      : CupertinoColors.systemGrey2.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoTextField(
                    controller: searchController,
                    focusNode: searchFocus,
                    autofocus: false,
                    placeholder: hintText,
                    placeholderStyle: AppTextStyle.textSm(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    style: AppTextStyle.textSm(
                      color: colors.onSurface,
                      weight: FontWeight.w500,
                    ),
                    textInputAction: TextInputAction.search,
                    decoration: null,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    onChanged: onSearchChanged,
                    onSubmitted: onSearchSubmitted,
                    clearButtonMode: OverlayVisibilityMode.editing,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          minimumSize: Size.zero,
          onPressed: () {
            HapticFeedback.lightImpact();
            if (searchFocus != null) searchFocus!.unfocus();
            final hadText = searchController.text.isNotEmpty;
            searchController.clear();
            if (hadText && onClear != null) {
              onClear!();
            }
            onToggleExpand(false);
          },
          child: Text(
            'Cancel',
            style: AppTextStyle.textSm(
              color: colors.primary,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Android Material 3 Search Bar ─────────────────────────────────────────

  Widget _buildAndroidSearchBar(
    BuildContext context,
    ColorScheme colors,
    bool isDark,
  ) {
    return Row(
      key: const ValueKey('android_material_search_bar'),
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(
                alpha: isDark ? 0.6 : 0.65,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colors.outlineVariant.withValues(
                  alpha: isDark ? 0.4 : 0.3,
                ),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocus,
                    autofocus: false,
                    textInputAction: TextInputAction.search,
                    style: AppTextStyle.textSm(
                      color: colors.onSurface,
                      weight: FontWeight.w500,
                    ),
                    onChanged: onSearchChanged,
                    onSubmitted: onSearchSubmitted,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: AppTextStyle.textSm(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: searchController,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                      splashRadius: 18,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        final hadText = searchController.text.isNotEmpty;
                        searchController.clear();
                        if (hadText && onClear != null) {
                          onClear!();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            if (searchFocus != null) searchFocus!.unfocus();
            final hadText = searchController.text.isNotEmpty;
            searchController.clear();
            if (hadText && onClear != null) {
              onClear!();
            }
            onToggleExpand(false);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Cancel',
            style: AppTextStyle.textSm(
              color: colors.primary,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable SliverPersistentHeader delegate for [AdaptiveExpandableSearchHeader].
class AdaptivePinnedSearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  const AdaptivePinnedSearchDelegate({
    required this.child,
    this.height = 70.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isScrolled = shrinkOffset > 0 || overlapsContent;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface.withValues(
                  alpha: isScrolled ? (isDark ? 0.88 : 0.92) : 1.0,
                ),
            boxShadow: isScrolled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.22 : 0.05,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              child,
              if (isScrolled)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.outline.withValues(
                            alpha: isDark ? 0.15 : 0.08,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant AdaptivePinnedSearchDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
