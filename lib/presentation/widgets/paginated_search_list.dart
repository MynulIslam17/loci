import 'package:flutter/material.dart';
import 'package:loci/presentation/widgets/pagination_loading.dart';

/// Compact dropdown list below a search field with scroll pagination.
class PaginatedSearchDropdown<T> extends StatelessWidget {
  final List<T> items;
  final ScrollController scrollController;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? emptyWidget;
  final double maxHeight;

  const PaginatedSearchDropdown({
    super.key,
    required this.items,
    required this.scrollController,
    required this.itemBuilder,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.onRetry,
    this.emptyWidget,
    this.maxHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading && items.isEmpty) {
      return _DropdownContainer(
        maxHeight: maxHeight,
        colorScheme: colorScheme,
        child: const _DefaultSearchShimmer(compact: true),
      );
    }

    if (errorMessage != null && items.isEmpty) {
      return _DropdownContainer(
        maxHeight: maxHeight,
        colorScheme: colorScheme,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage!, style: const TextStyle(fontSize: 13)),
              if (onRetry != null)
                TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return emptyWidget ?? const SizedBox.shrink();
    }

    return _DropdownContainer(
      maxHeight: maxHeight,
      colorScheme: colorScheme,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: items.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const PaginationLoader(padding: 8, size: 20);
          }
          return itemBuilder(context, items[index], index);
        },
      ),
    );
  }
}

class _DropdownContainer extends StatelessWidget {
  final Widget child;
  final double maxHeight;
  final ColorScheme colorScheme;

  const _DropdownContainer({
    required this.child,
    required this.maxHeight,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      color: colorScheme.surfaceContainer,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: child,
        ),
      ),
    );
  }
}

/// Reusable vertical search-result list with [ScrollController] pagination.
/// Returns slivers for use inside a [CustomScrollView].
class PaginatedSearchListSliver<T> extends StatelessWidget {
  final List<T> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? emptyWidget;
  final Widget? initialLoadingWidget;

  const PaginatedSearchListSliver({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.onRetry,
    this.emptyWidget,
    this.initialLoadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return SliverToBoxAdapter(
        child: initialLoadingWidget ?? const _DefaultSearchShimmer(),
      );
    }

    if (errorMessage != null && items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(errorMessage!),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return SliverToBoxAdapter(child: emptyWidget ?? const SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == items.length) {
            return const PaginationLoader();
          }
          return itemBuilder(context, items[index], index);
        },
        childCount: items.length + (isLoadingMore ? 1 : 0),
      ),
    );
  }
}

class _DefaultSearchShimmer extends StatelessWidget {
  final bool compact;

  const _DefaultSearchShimmer({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final count = compact ? 3 : 4;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compact ? 10 : 14,
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
