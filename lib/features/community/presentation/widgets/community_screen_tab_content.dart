import 'package:flutter/material.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/features/community/presentation/controllers/community_screen_controller.dart';
import 'package:loci/features/community/presentation/widgets/community_feed_shimmer.dart';
import 'package:loci/features/community/presentation/widgets/community_search_bar.dart';
import 'package:loci/features/community/presentation/widgets/community_tab_shimmers.dart';
import 'package:loci/features/community/presentation/widgets/community_ui_constants.dart';
import 'package:loci/features/community/presentation/widgets/tabs/activity_tab.dart';
import 'package:loci/features/community/presentation/widgets/tabs/feed_tab.dart';
import 'package:loci/features/community/presentation/widgets/tabs/notices_tab.dart';
import 'package:loci/features/community/presentation/widgets/tabs/offers_tab.dart';
import 'package:loci/features/community/presentation/widgets/tabs/tab_body_wrapper.dart';
import 'package:loci/shared/widgets/feed/post_input_field.dart';

class CommunityScreenTabContent extends StatelessWidget {
  const CommunityScreenTabContent({
    super.key,
    required this.screen,
    required this.tabController,
    required this.searchControllers,
  });

  final CommunityScreenController screen;
  final TabController tabController;
  final List<TextEditingController> searchControllers;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        TabBodyWrapper(
          tabType: AnnouncementType.question,
          shimmerBuilder: (_) => const CommunityFeedShimmer(),
          stickyHeader: Padding(
            padding: CommunityUi.stickyHeaderPadding,
            child: PostInputField(
              categories: BusinessCategory.values.map((e) => e.label).toList(),
              initialCategory: BusinessCategory.foodie.label,
              onSubmit: screen.postQuestion,
              hintText: 'Post a question...',
            ),
          ),
          builder: () => FeedTab(
            onCommentTap: (id) => screen.openComments(context, id),
            onPollTap: (a) => screen.openPollSheet(context, a),
            onLikeTap: screen.toggleLike,
            onMentionSubmit: screen.submitMentionOption,
          ),
        ),
        _searchableTab(
          tabIndex: 1,
          type: AnnouncementType.offer,
          hint: 'Search offers',
          shimmer: const CommunityOffersListShimmer(),
          child: OffersTab(
            onCommentTap: (id) => screen.openComments(context, id),
            onLikeTap: screen.toggleLike,
          ),
        ),
        _searchableTab(
          tabIndex: 2,
          type: AnnouncementType.notice,
          hint: 'Search notices',
          shimmer: const CommunityNoticesListShimmer(),
          child: NoticesTab(
            onCommentTap: (id) => screen.openComments(context, id),
            onLikeTap: screen.toggleLike,
          ),
        ),
        _searchableTab(
          tabIndex: 3,
          type: AnnouncementType.activity,
          hint: 'Search activity',
          shimmer: const CommunityActivityListShimmer(),
          child: ActivityTab(
            onCommentTap: (id) => screen.openComments(context, id),
            onLikeTap: screen.toggleLike,
            onRsvp: screen.submitRsvp,
          ),
        ),
      ],
    );
  }

  Widget _searchableTab({
    required int tabIndex,
    required AnnouncementType type,
    required String hint,
    required Widget shimmer,
    required Widget child,
  }) {
    final searchController = searchControllers[tabIndex];
    return TabBodyWrapper(
      tabType: type,
      shimmerBuilder: (_) => shimmer,
      stickyHeader: Padding(
        padding: CommunityUi.stickyHeaderPadding,
        child: CommunitySearchBar(
          controller: searchController,
          hintText: hint,
          onChanged: (value) => screen.onSearchChanged(tabController, value),
          onClear: () =>
              screen.clearSearch(tabController, searchController),
        ),
      ),
      builder: () => child,
    );
  }
}
