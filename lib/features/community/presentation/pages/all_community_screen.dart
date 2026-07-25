import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/community/presentation/controllers/join_community_controller.dart';
import 'package:loci/features/community/presentation/widgets/community_card.dart';
import 'package:loci/features/community/presentation/widgets/community_shimmer.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/features/home/presentation/pages/home_navigator.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/features/community/presentation/controllers/all_community_controller.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class AllCommunityScreen extends StatelessWidget {
  AllCommunityScreen({super.key});
  final controller = Get.find<AllCommunityController>();
  final joinController = Get.find<JoinCommunityController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Communities"),
      body: Obx(() {
        final hasFatalError =
            controller.errorMessage.value != null &&
            controller.joined.isEmpty &&
            controller.available.isEmpty &&
            !controller.isLoading.value;

        if (hasFatalError) {
          return ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: controller.refreshCommunities,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshCommunities,
          child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "Search Community",
                  borderColor: colorScheme.outline,
                  fontSize: 14,
                  textColor: colorScheme.onSurface,
                  hintTextColor: colorScheme.onSurfaceVariant,
                  suffixIcon: Icon(
                    Icons.search,
                    size: 22,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "My Community",
                  style: AppTextStyle.textLg(weight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (controller.isLoading.value && controller.joined.isEmpty)
                  CommunitySkeleton.list(count: 2)
                else if (controller.joined.isEmpty)
                  const EmptyState(
                    icon: Icons.groups_outlined,
                    title: "No joined communities",
                    subtitle: "Try again later or check joined communities",
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.joined.length,
                    itemBuilder: (context, index) {
                      final joinedCommunity = controller.joined[index];
                      return CommunityCard(
                        communityOnTap: () {
                          //TODO : go to community view page
                          HomeNavigator.push(
                            AppRoutes.communityScreen,
                            arguments: {
                              "communityRole": joinedCommunity.role,
                              "communityId": joinedCommunity.id,
                              "communityName": joinedCommunity.name,
                            },
                          );
                        },
                        title: joinedCommunity.name,
                        communityLogo: joinedCommunity.image,
                        category: joinedCommunity.category.label,
                        members: joinedCommunity.members,
                        description: joinedCommunity.description,
                        role: joinedCommunity.role,
                      );
                    },
                  ),
                const SizedBox(height: 24),

                //-------------business community------------------
                Text(
                  "Business Communities",
                  style: AppTextStyle.textLg(weight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                if (controller.isLoading.value && controller.available.isEmpty)
                  CommunitySkeleton.list(count: 2)
                else if (controller.available.isEmpty)
                  const EmptyState(
                    icon: Icons.groups_outlined,
                    title: "No communities available",
                    subtitle: "Try again later or check joined communities",
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    // ALWAYS +1 (stable pattern)
                    itemCount: controller.available.length + 1,

                    itemBuilder: (context, index) {
                      // ================= LOADER =================
                      if (index == controller.available.length) {
                        // show pagination loader
                        if (controller.isPaginationLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        // show "no more" message
                        if (!controller.hasMore &&
                            controller.available.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                "No more communities",
                                style: AppTextStyle.textSm(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      }

                      // ================= NORMAL ITEM =================
                      final community = controller.available[index];

                      return Obx(() {
                        // Subscribe to per-item join loading.
                        joinController.joiningId.value;
                        return CommunityCard(
                          onJoinTap: () =>
                              _joinHandler(community.qrCode, joinController),
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
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _joinHandler(
    String joinCode,
    JoinCommunityController joinController,
  ) async {
    joinController.joinCommunity(joinId: joinCode);
  }
}
