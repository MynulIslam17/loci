import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/data/models/community_model.dart';
import 'package:loci/features/community/presentation/controllers/all_community_controller.dart';
import 'package:loci/features/community/presentation/controllers/join_community_controller.dart';
import 'package:loci/features/community/presentation/widgets/all_communities/all_communities_constants.dart';
import 'package:loci/features/community/presentation/widgets/community_card.dart';
import 'package:loci/features/community/presentation/widgets/community_shimmer.dart';
import 'package:loci/shared/widgets/empty_state.dart';

class BusinessCommunitiesSection extends StatelessWidget {
  const BusinessCommunitiesSection({
    super.key,
    required this.listController,
    required this.joinController,
  });

  final AllCommunityController listController;
  final JoinCommunityController joinController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = listController.isLoading.value;
      final available = listController.displayedAvailable;
      final hasSource = listController.available.isNotEmpty;
      final searching = listController.isSearching;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Communities',
            style: AppTextStyle.textLg(weight: FontWeight.bold),
          ),
          const SizedBox(height: AllCommunitiesUi.sectionListGap),
          if (isLoading && !hasSource)
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
            _BusinessCommunityList(
              controller: listController,
              joinController: joinController,
              items: available,
            ),
        ],
      );
    });
  }
}

class _BusinessCommunityList extends StatelessWidget {
  const _BusinessCommunityList({
    required this.controller,
    required this.joinController,
    required this.items,
  });

  final AllCommunityController controller;
  final JoinCommunityController joinController;
  final List<CommunityModel> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length + 1,
      separatorBuilder: (_, index) {
        if (index >= items.length - 1) return const SizedBox.shrink();
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _PaginationFooter(
            controller: controller,
            colorScheme: colorScheme,
          );
        }

        final community = items[index];
        return Obx(() {
          joinController.joiningId.value;
          return CommunityCard(
            onJoinTap: () =>
                joinController.joinCommunity(joinId: community.qrCode),
            isJoining: joinController.isJoining(community.qrCode),
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
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.controller,
    required this.colorScheme,
  });

  final AllCommunityController controller;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isPaginationLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(
            vertical: AllCommunitiesUi.paginationVertical,
          ),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (!controller.hasMore && controller.available.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AllCommunitiesUi.paginationVertical,
          ),
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
