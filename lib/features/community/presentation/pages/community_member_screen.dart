import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/community/presentation/controllers/community_member_controller.dart';
import 'package:loci/features/community/presentation/widgets/add_community_member_sheet.dart';
import 'package:loci/features/community/presentation/widgets/community_search_bar.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/features/community/presentation/widgets/member_card.dart';
import 'package:loci/features/community/presentation/widgets/member_list_header.dart';
import 'package:loci/features/community/presentation/widgets/member_shimmer.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';

class CommunityMemberScreen extends StatefulWidget {
  const CommunityMemberScreen({super.key});

  @override
  State<CommunityMemberScreen> createState() => _CommunityMemberScreenState();
}

class _CommunityMemberScreenState extends State<CommunityMemberScreen> {
  final memberController = Get.find<CommunityMemberController>();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  late final String communityId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    communityId = args?['communityId']?.toString() ?? '';
    if (communityId.isNotEmpty) {
      memberController.init(communityId: communityId);
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

  Future<void> _onAddMember() async {
    await AddCommunityMemberSheet.show(
      context,
      onSubmit: (payload) async {
        final ok = await memberController.addMember(
          email: payload.email,
          note: payload.note,
        );
        if (!ok && mounted) {
          SnackbarService.error(
            memberController.errorMessage.value ?? 'Failed to add member',
          );
        } else if (ok) {
          SnackbarService.success(
            memberController.successMessage.value ?? 'Invitation sent',
          );
        }
        return ok;
      },
    );
  }

  Future<void> _onExport() async {
    final saved = await memberController.exportMembers();
    if (!mounted) return;
    if (saved) {
      SnackbarService.success('Member list saved');
    } else if (memberController.errorMessage.value != null) {
      SnackbarService.error(memberController.errorMessage.value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: CustomAppbar(title: 'Community Members'),
      body: AdaptiveRefresh(
        onRefresh: memberController.refreshMembers,
        color: colors.primary,
        child: Obx(() {
          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CommunitySearchBar(
                        controller: _searchController,
                        hintText: 'Search members...',
                        onChanged: memberController.onSearchChanged,
                        onClear: () {
                          _searchController.clear();
                          memberController.clearSearch();
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        width: double.infinity,
                        height: 50,
                        onPressed: _onAddMember,
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
              SliverToBoxAdapter(
                child: MemberListHeader(
                  count: memberController.totalCount.value,
                  isLoading:
                      memberController.isInitialLoading &&
                      memberController.totalCount.value == 0,
                  isExporting: memberController.isExporting.value,
                  onExport: communityId.isEmpty ? null : _onExport,
                ),
              ),
              if (memberController.showInitialShimmer &&
                  memberController.members.isEmpty)
                const MemberListShimmer()
              else if (memberController.members.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.group_off,
                    title: 'No members yet',
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
                          final success = await memberController.removeMember(
                            member.id,
                          );
                          if (!mounted) return;
                          if (success) {
                            SnackbarService.success('Member removed');
                          } else {
                            SnackbarService.error(
                              memberController.errorMessage.value ??
                                  'Failed to remove member',
                            );
                          }
                        },
                      );
                    }, childCount: memberController.members.length),
                  ),
                ),
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
      ),
    );
  }
}
