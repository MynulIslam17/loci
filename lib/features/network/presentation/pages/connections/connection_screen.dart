import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/network/data/models/connection_item.dart';
import 'package:loci/features/network/presentation/controllers/connections_controller.dart';
import 'package:loci/features/network/presentation/widgets/connections/connection_card.dart';
import 'package:loci/features/network/presentation/widgets/connections/connection_shimmer.dart';
import 'package:loci/shared/widgets/adaptive_expandable_search_header.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _controller = Get.find<ConnectionsController>();
  final _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = _controller.searchQuery;
    _isSearchExpanded = _controller.searchQuery.isNotEmpty;
  }

  void _resetSearchToDefault() {
    if (_isSearchExpanded || _searchController.text.isNotEmpty) {
      if (mounted) {
        setState(() {
          _isSearchExpanded = false;
        });
      }
      _searchFocus.unfocus();
      _searchController.clear();
      _controller.clearSearch();
    }
  }

  @override
  void dispose() {
    _resetSearchToDefault();
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() => _controller.refreshConnections();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const CustomAppbar(title: 'Connections'),
      body: Obx(() {
        if (_controller.showInitialShimmer) {
          return AdaptiveRefresh(
            onRefresh: _onRefresh,
            child: const ConnectionScreenShimmer(),
          );
        }

        final filtered = _controller.filteredConnections;
        final showSearchEmpty =
            _controller.connections.isNotEmpty &&
            _controller.searchQuery.trim().isNotEmpty &&
            filtered.isEmpty;

        final contactCount = _controller.connections.length;
        final subtitle =
            '$contactCount ${contactCount == 1 ? 'contact' : 'contacts'} in your network';

        return AdaptiveRefresh(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AdaptiveExpandableSearchHeader(
                    title: 'Your Network',
                    subtitle: subtitle,
                    hintText: 'Search connections...',
                    searchController: _searchController,
                    searchFocus: _searchFocus,
                    isExpanded: _isSearchExpanded ||
                        _controller.searchQuery.isNotEmpty,
                    onToggleExpand: (expanded) {
                      setState(() => _isSearchExpanded = expanded);
                    },
                    onSearchChanged: _controller.onSearchChanged,
                    onClear: () {
                      _controller.clearSearch();
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              if (showSearchEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'No matching connections',
                    subtitle: 'Try a different name, email, or company',
                  ),
                )
              else
                _buildConnectionsList(filtered),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildConnectionsList(List<ConnectionModel> connections) {
    if (_controller.errorMessage != null && connections.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorStateWidget(
          message: _controller.errorMessage!,
          onRetry: _controller.fetchConnections,
        ),
      );
    }

    if (connections.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.people_outline,
          title: 'No connections yet',
          subtitle: 'Your network contacts will appear here',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList.separated(
        itemCount: connections.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final connection = connections[index];
          return Obx(
            () => ConnectionCard(
              connection: connection,
              isRemoving: _controller.isRemoving(connection.id),
              onRemove: () => _controller.removeConnection(connection),
            ),
          );
        },
      ),
    );
  }
}
