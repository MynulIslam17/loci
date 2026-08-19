import 'package:flutter/cupertino.dart' hide RefreshCallback;
import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Pull-to-refresh that matches the host platform.
///
/// * **iOS** — [CupertinoSliverRefreshControl] (rubber-band spinner in the
///   overscroll gap), used whenever [slivers] are provided. For an existing
///   scrollable [child], [RefreshIndicator.adaptive] shows the Cupertino
///   spinner.
/// * **Android** — Material [RefreshIndicator].
class AdaptiveRefresh extends StatelessWidget {
  const AdaptiveRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.strokeWidth = RefreshProgressIndicator.defaultStrokeWidth,
  }) : slivers = null,
       controller = null,
       physics = null,
       keyboardDismissBehavior = null;

  /// Native refresh around a [CustomScrollView].
  ///
  /// iOS inserts [CupertinoSliverRefreshControl] as the first sliver.
  /// Android wraps the scroll view in a Material [RefreshIndicator].
  const AdaptiveRefresh.scroll({
    super.key,
    required this.onRefresh,
    required List<Widget> this.slivers,
    this.controller,
    this.physics,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.strokeWidth = RefreshProgressIndicator.defaultStrokeWidth,
    this.keyboardDismissBehavior,
  }) : child = null;

  final RefreshCallback onRefresh;
  final Widget? child;
  final List<Widget>? slivers;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;
  final ScrollNotificationPredicate notificationPredicate;
  final RefreshIndicatorTriggerMode triggerMode;
  final double strokeWidth;
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  @override
  Widget build(BuildContext context) {
    if (slivers != null) {
      return _buildScroll(context, slivers!);
    }
    return _buildChild(context, child!);
  }

  Widget _buildChild(BuildContext context, Widget child) {
    final effectiveColor = color ?? context.colorScheme.primary;
    final effectiveBgColor =
        backgroundColor ?? context.colorScheme.surfaceContainerHigh;

    if (context.isCupertino) {
      return RefreshIndicator.adaptive(
        onRefresh: onRefresh,
        color: effectiveColor,
        backgroundColor: effectiveBgColor,
        displacement: displacement,
        edgeOffset: edgeOffset,
        notificationPredicate: notificationPredicate,
        triggerMode: triggerMode,
        strokeWidth: strokeWidth,
        child: child,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: effectiveColor,
      backgroundColor: effectiveBgColor,
      displacement: displacement,
      edgeOffset: edgeOffset,
      notificationPredicate: notificationPredicate,
      triggerMode: triggerMode,
      strokeWidth: strokeWidth,
      child: child,
    );
  }

  Widget _buildScroll(BuildContext context, List<Widget> slivers) {
    final isIOS = context.isCupertino;
    final effectiveColor = color ?? context.colorScheme.primary;
    final effectiveBgColor =
        backgroundColor ?? context.colorScheme.surfaceContainerHigh;

    final scrollView = CustomScrollView(
      controller: controller,
      physics:
          physics ??
          (isIOS
              ? const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                )
              : const AlwaysScrollableScrollPhysics()),
      keyboardDismissBehavior:
          keyboardDismissBehavior ?? ScrollViewKeyboardDismissBehavior.manual,
      slivers: [
        if (isIOS) CupertinoSliverRefreshControl(onRefresh: onRefresh),
        ...slivers,
      ],
    );

    if (isIOS) return scrollView;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: effectiveColor,
      backgroundColor: effectiveBgColor,
      displacement: displacement,
      edgeOffset: edgeOffset,
      notificationPredicate: notificationPredicate,
      triggerMode: triggerMode,
      strokeWidth: strokeWidth,
      child: scrollView,
    );
  }
}
