import 'package:flutter/material.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_detail_shimmer.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/error_state.dart';

/// Loading / error / content switch used on edit and view screens.
class ExploreActivityAsyncBody extends StatelessWidget {
  const ExploreActivityAsyncBody({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.isEmpty,
    required this.emptyMessage,
    required this.builder,
    this.loading,
    this.onRefresh,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final bool isEmpty;
  final String emptyMessage;
  final Widget Function(BuildContext context) builder;

  /// Defaults to [ExploreActivityDetailShimmer] (view + edit).
  final Widget? loading;

  /// When set, wraps content in [AdaptiveRefresh] (no shimmer on pull).
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    // First load only — keep existing content visible during pull refresh.
    if (isLoading && isEmpty) {
      return loading ?? const ExploreActivityDetailShimmer();
    }

    if (errorMessage != null && isEmpty) {
      return ErrorStateWidget(message: errorMessage!, onRetry: onRetry);
    }

    if (isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    final content = builder(context);
    if (onRefresh == null) return content;

    return AdaptiveRefresh(
      onRefresh: onRefresh!,
      child: content,
    );
  }
}
