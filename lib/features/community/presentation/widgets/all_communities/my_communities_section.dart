import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/features/community/data/models/community_model.dart';
import 'package:loci/features/community/presentation/controllers/all_community_controller.dart';
import 'package:loci/features/community/presentation/widgets/all_communities/all_communities_constants.dart';
import 'package:loci/features/community/presentation/widgets/community_card.dart';
import 'package:loci/features/community/presentation/widgets/community_shimmer.dart';
import 'package:loci/shared/widgets/empty_state.dart';

class MyCommunitiesSection extends StatelessWidget {
  const MyCommunitiesSection({super.key, required this.controller});

  final AllCommunityController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final joined = controller.displayedJoined;
      final hasSource = controller.joined.isNotEmpty;
      final searching = controller.isSearching;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Community',
            style: AppTextStyle.textLg(weight: FontWeight.bold),
          ),
          const SizedBox(height: AllCommunitiesUi.sectionListGap),
          if (isLoading && !hasSource)
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
            _CommunityList(
              items: joined,
              onTap: controller.openCommunity,
            ),
        ],
      );
    });
  }
}

class _CommunityList extends StatelessWidget {
  const _CommunityList({required this.items, required this.onTap});

  final List<CommunityModel> items;
  final void Function(CommunityModel) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final community = items[index];
        return CommunityCard(
          communityOnTap: () => onTap(community),
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
}
