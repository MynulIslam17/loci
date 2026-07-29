import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/community/presentation/controllers/all_community_controller.dart';
import 'package:loci/features/community/presentation/controllers/join_community_controller.dart';
import 'package:loci/features/community/presentation/widgets/all_communities/all_communities_constants.dart';
import 'package:loci/features/community/presentation/widgets/all_communities/all_communities_search_bar.dart';
import 'package:loci/features/community/presentation/widgets/all_communities/business_communities_section.dart';
import 'package:loci/features/community/presentation/widgets/all_communities/my_communities_section.dart';
import 'package:loci/shared/widgets/error_state.dart';

class AllCommunitiesBody extends StatefulWidget {
  const AllCommunitiesBody({super.key});

  @override
  State<AllCommunitiesBody> createState() => _AllCommunitiesBodyState();
}

class _AllCommunitiesBodyState extends State<AllCommunitiesBody> {
  final _listController = Get.find<AllCommunityController>();
  final _joinController = Get.find<JoinCommunityController>();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Obx(() {
      final fatalError = _listController.errorMessage.value != null &&
          _listController.joined.isEmpty &&
          _listController.available.isEmpty &&
          !_listController.isLoading.value;

      if (fatalError) {
        return ErrorStateWidget(
          message: _listController.errorMessage.value!,
          onRetry: _listController.refreshCommunities,
        );
      }

      return RefreshIndicator(
        onRefresh: _listController.refreshCommunities,
        color: colorScheme.primary,
        child: SingleChildScrollView(
          controller: _listController.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AllCommunitiesUi.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AllCommunitiesSearchBar(
                controller: _listController,
                textController: _searchController,
              ),
              const SizedBox(height: AllCommunitiesUi.sectionTitleGap),
              MyCommunitiesSection(controller: _listController),
              const SizedBox(height: AllCommunitiesUi.sectionTitleGap),
              BusinessCommunitiesSection(
                listController: _listController,
                joinController: _joinController,
              ),
              const SizedBox(height: AllCommunitiesUi.sectionTitleGap),
            ],
          ),
        ),
      );
    });
  }
}
