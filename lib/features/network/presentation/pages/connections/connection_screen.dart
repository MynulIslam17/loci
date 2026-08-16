import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/network/data/models/connection_item.dart';
import 'package:loci/features/network/presentation/controllers/connections_controller.dart';
import 'package:loci/features/network/presentation/widgets/connections/connection_card.dart';
import 'package:loci/features/network/presentation/widgets/connections/connection_shimmer.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.text = _controller.searchQuery;
  }

  @override
  void dispose() {
    _controller.clearSearch();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() => _controller.refreshConnections();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Connections',
          style: AppTextStyle.textLg(weight: FontWeight.w700),
        ),
      ),
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

        return AdaptiveRefresh(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _searchController,
                        hintText: 'Search connections ..',
                        textColor: colors.onSurface,
                        borderColor: colors.outline,
                        onChanged: _controller.onSearchChanged,
                        showClearButton: true,
                        onClear: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                          _controller.clearSearch();
                        },
                        suffixIcon: Icon(
                          Icons.search,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your network',
                        style: AppTextStyle.textXl(weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_controller.connections.length} '
                        '${_controller.connections.length == 1 ? 'contact' : 'contacts'}',
                        style: AppTextStyle.textSm(
                          color: colors.onSurfaceVariant,
                          weight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
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
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
