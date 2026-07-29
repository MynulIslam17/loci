import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/community/presentation/controllers/community_member_controller.dart';
import 'package:loci/features/community/presentation/controllers/remove_member_controller.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/features/community/presentation/widgets/member_card.dart';
import 'package:loci/features/community/presentation/widgets/member_list_header.dart';
import 'package:loci/features/community/presentation/widgets/member_shimmer.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class CommunityMemberScreen extends StatefulWidget {
  const CommunityMemberScreen({super.key});

  @override
  State<CommunityMemberScreen> createState() => _CommunityMemberScreenState();
}

class _CommunityMemberScreenState extends State<CommunityMemberScreen> {
  final memberController = Get.find<CommunityMemberController>();
  final removeController = Get.find<RemoveMemberController>();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  late final String communityId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    communityId = args?['communityId'] ?? '';
    if (communityId.isNotEmpty) {
      memberController.init(communityId);
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      memberController.fetchMoreMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: CustomAppbar(title: 'Community Members'),
      body: Obx(() {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Search + Add Member ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _searchController,
                      hintText: 'Search members...',
                      borderColor: colors.outline,
                      fontSize: 14,
                      textColor: colors.onSurface,
                      hintTextColor: colors.onSurfaceVariant,
                      onChanged: memberController.onSearchChanged,
                      showClearButton: true,
                      onClear: memberController.clearSearch,
                      suffixIcon: Icon(
                        Icons.search,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      width: double.infinity,
                      height: 50,
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add,
                            size: 22,
                            color: colors.onPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add Member',
                            style: AppTextStyle.textMd(
                              weight: FontWeight.w600,
                              color: colors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Header ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: MemberListHeader(
                count: memberController.totalCount.value,
                isLoading:
                    memberController.isLoading.value &&
                    memberController.totalCount.value == 0,
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            if (memberController.isLoading.value)
              const MemberListShimmer()
            else if (memberController.members.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.group_off,
                  title: "No members yet",
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final member = memberController.members[index];
                    return MemberCard(
                      member: member,
                      onDelete: () async {
                        final success = await removeController.removeMember(
                          communityId: communityId,
                          memberId: member.id,
                        );
                        if (success) {
                          memberController.fetchMembers(isRefresh: true);
                        } else {
                          SnackbarService.error(
                            removeController.errorMessage.value ??
                                'Failed to remove member',
                          );
                        }
                      },
                    );
                  }, childCount: memberController.members.length),
                ),
              ),

            // ── Pagination loader ─────────────────────────────────────────
            if (memberController.isPaginationLoading.value)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      }),
    );
  }
}
