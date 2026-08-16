import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/community/data/models/community_model.dart';
import 'package:loci/features/community/presentation/controllers/all_community_controller.dart';
import 'package:loci/features/community/presentation/controllers/join_community_controller.dart';
import 'package:loci/features/community/presentation/widgets/community_card.dart';
import 'package:loci/features/community/presentation/widgets/community_search_bar.dart';
import 'package:loci/features/community/presentation/widgets/community_shimmer.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';

/// Communities hub: joined list + discover/join business communities.
///
/// Flow: UI → [AllCommunityController] / [JoinCommunityController]
/// → [CommunityService] → repository → API.
class AllCommunityScreen extends StatefulWidget {
  const AllCommunityScreen({super.key});

  @override
  State<AllCommunityScreen> createState() => _AllCommunityScreenState();
}

class _AllCommunityScreenState extends State<AllCommunityScreen> {
  static const _horizontalPadding = 16.0;
  static const _searchTop = 8.0;
  static const _sectionGap = 24.0;
  static const _listGap = 12.0;
  static const _paginationVertical = 16.0;

  final _listController = Get.find<AllCommunityController>();
  final _joinController = Get.find<JoinCommunityController>();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onJoinCommunity(CommunityModel community) async {
    final ok = await _joinController.joinCommunity(joinId: community.qrCode);
    if (!mounted) return;
    if (ok) {
      SnackbarService.success(
        _joinController.successMessage.value ?? 'Successfully joined community',
      );
    } else {
      SnackbarService.error(
        _joinController.errorMessage.value ?? 'Could not join community',
      );
    }
  }

  void _onSearchClear() {
    _searchController.clear();
    _listController.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: 'Communities'),
      body: Obx(() {
        if (_listController.hasFatalLoadError) {
          return ErrorStateWidget(
            message: _listController.errorMessage.value!,
            onRetry: _listController.refreshCommunities,
          );
        }

        return AdaptiveRefresh(
          onRefresh: _listController.refreshCommunities,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            controller: _listController.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: _searchTop),
                  child: CommunitySearchBar(
                    controller: _searchController,
                    hintText: 'Search communities',
                    onChanged: _listController.onSearchChanged,
                    onClear: _onSearchClear,
                  ),
                ),
                const SizedBox(height: _sectionGap),
                _buildMyCommunitiesSection(),
                const SizedBox(height: _sectionGap),
                _buildBusinessCommunitiesSection(colorScheme),
                const SizedBox(height: _sectionGap),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMyCommunitiesSection() {
    final showShimmer = _listController.showInitialShimmer;
    final joined = _listController.displayedJoined;
    final hasSource = _listController.joined.isNotEmpty;
    final searching = _listController.isSearching;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Community',
          style: AppTextStyle.textLg(weight: FontWeight.bold),
        ),
        const SizedBox(height: _listGap),
        if (showShimmer && !hasSource)
          CommunitySkeleton.list(count: 2)
        else if (!hasSource)
          const EmptyState(
            icon: Icons.groups_outlined,
            title: 'No joined communities',
            subtitle: 'Join a business community below to get started',
          )
        else if (joined.isEmpty && searching)
          const EmptyState(
            icon: Icons.search_off_outlined,
            title: 'No matches',
            subtitle: 'Try a different search term',
          )
        else
          _joinedCommunityList(joined),
      ],
    );
  }

  Widget _joinedCommunityList(List<CommunityModel> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: _listGap),
      itemBuilder: (context, index) {
        final community = items[index];
        return CommunityCard(
          communityOnTap: () => _listController.openCommunity(community),
          title: community.name,
          communityLogo: community.image,
          category: community.category.label,
          members: community.members,
          description: community.description,
          role: community.role,
        );
      },
    );
  }

  Widget _buildBusinessCommunitiesSection(ColorScheme colorScheme) {
    final showShimmer = _listController.showInitialShimmer;
    final available = _listController.displayedAvailable;
    final hasSource = _listController.available.isNotEmpty;
    final searching = _listController.isSearching;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Communities',
          style: AppTextStyle.textLg(weight: FontWeight.bold),
        ),
        const SizedBox(height: _listGap),
        if (showShimmer && !hasSource)
          CommunitySkeleton.list(count: 2)
        else if (!hasSource)
          const EmptyState(
            icon: Icons.groups_outlined,
            title: 'No communities available',
            subtitle: 'Check back later for new communities',
          )
        else if (available.isEmpty && searching)
          const EmptyState(
            icon: Icons.search_off_outlined,
            title: 'No matches',
            subtitle: 'Try a different search term',
          )
        else
          _businessCommunityList(available, colorScheme),
      ],
    );
  }

  Widget _businessCommunityList(
    List<CommunityModel> items,
    ColorScheme colorScheme,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length + 1,
      separatorBuilder: (_, index) {
        if (index >= items.length - 1) return const SizedBox.shrink();
        return const SizedBox(height: _listGap);
      },
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _buildPaginationFooter(colorScheme);
        }

        final community = items[index];
        return Obx(() {
          _joinController.joiningId.value;
          return CommunityCard(
            onJoinTap: () => _onJoinCommunity(community),
            isJoining: _joinController.isJoining(community.qrCode),
            title: community.name,
            communityLogo: community.image,
            category: community.category.label,
            members: community.members,
            description: community.description,
            role: null,
          );
        });
      },
    );
  }

  Widget _buildPaginationFooter(ColorScheme colorScheme) {
    return Obx(() {
      if (_listController.showPaginationLoader) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: _paginationVertical),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (_listController.showEndOfAvailableList) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: _paginationVertical),
          child: Center(
            child: Text(
              'No more communities',
              style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }
}
