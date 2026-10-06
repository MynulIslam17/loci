import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Visual style for the Android fallback tab bar.
enum AdaptiveTabBarStyle {
  /// Styled capsule/pill indicator (e.g. Subscription details, dialogs).
  pill,

  /// Clean line indicator for sticky headers, slivers, and nested scroll views.
  underline,
}

/// A universal adaptive tab bar that renders Apple's native [CNSegmentedControl]
/// on iOS and a properly styled Material [TabBar] on Android.
class AdaptiveTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveTabBar({
    super.key,
    required this.labels,
    this.controller,
    this.onTap,
    this.isScrollable = false,
    this.style = AdaptiveTabBarStyle.pill,
    this.height,
    this.iosHeight = 32.0,
    this.backgroundColor,
    this.padding,
  });

  /// The list of tab labels to display.
  final List<String> labels;

  /// Optional [TabController]. If null, resolves [DefaultTabController.of(context)].
  final TabController? controller;

  /// Optional callback invoked when a tab is selected.
  final ValueChanged<int>? onTap;

  /// Whether the Android TabBar should scroll horizontally.
  final bool isScrollable;

  /// Visual style for the Android TabBar (pill vs line underline).
  final AdaptiveTabBarStyle style;

  /// Explicit widget height. If null, calculates based on [style].
  final double? height;

  /// Height for the native iOS [CNSegmentedControl]. Defaults to 32.0.
  final double iosHeight;

  /// Background color of the container.
  final Color? backgroundColor;

  /// Outer padding around the control.
  final EdgeInsetsGeometry? padding;

  @override
  Size get preferredSize {
    if (height != null) return Size.fromHeight(height!);
    return Size.fromHeight(
      style == AdaptiveTabBarStyle.pill ? 48.0 : kTextTabBarHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _buildIosSegmentedControl(context);
    }
    return _buildAndroidTabBar(context);
  }

  Widget _buildIosSegmentedControl(BuildContext context) {
    final TabController? effectiveController =
        controller ?? DefaultTabController.maybeOf(context);

    Widget buildControl(TabController? tabCtrl) {
      final int activeIndex = (tabCtrl?.index ?? 0).clamp(0, labels.length - 1);
      return SizedBox(
        width: double.infinity,
        child: CNSegmentedControl(
          labels: labels,
          selectedIndex: activeIndex,
          height: iosHeight,
          shrinkWrap: isScrollable,
          onValueChanged: (int index) {
            tabCtrl?.animateTo(index);
            onTap?.call(index);
          },
        ),
      );
    }

    final Widget controlWidget;
    if (effectiveController != null) {
      controlWidget = AnimatedBuilder(
        animation: effectiveController,
        builder: (BuildContext context, Widget? child) =>
            buildControl(effectiveController),
      );
    } else {
      controlWidget = buildControl(null);
    }

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Theme.of(context).brightness,
        primaryColor: context.colorScheme.primary,
      ),
      child: Container(
        color: backgroundColor,
        padding: padding ?? EdgeInsets.zero,
        child: controlWidget,
      ),
    );
  }

  Widget _buildAndroidTabBar(BuildContext context) {
    final TabController? effectiveController =
        controller ?? DefaultTabController.maybeOf(context);
    final colorScheme = context.colorScheme;

    if (style == AdaptiveTabBarStyle.pill) {
      return Container(
        height: height ?? 48,
        color: backgroundColor,
        padding: padding ?? const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0F9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TabBar(
            controller: effectiveController,
            indicator: BoxDecoration(
              color: const Color(0xFF0866E8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF0866E8).withValues(alpha: .22),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorAnimation: TabIndicatorAnimation.elastic,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF123266),
            dividerColor: Colors.transparent,
            labelStyle: AppTextStyle.textSm(weight: FontWeight.w700),
            tabs: [for (final label in labels) Tab(text: label)],
            onTap: onTap,
          ),
        ),
      );
    }

    return Container(
      color: backgroundColor,
      padding: padding ?? EdgeInsets.zero,
      child: TabBar(
        controller: effectiveController,
        isScrollable: isScrollable,
        tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
        labelStyle: AppTextStyle.textSm(weight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyle.textSm(),
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [for (final label in labels) Tab(text: label)],
        onTap: onTap,
      ),
    );
  }
}
