import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/recent_activity.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/presentation/controllers/recent_activity/recent_activity_controller.dart';
import 'package:loci/presentation/pages/recent_activity/widgets/answer_activity_card.dart';
import 'package:loci/presentation/pages/recent_activity/widgets/business_actvity_card.dart';
import 'package:loci/presentation/pages/recent_activity/widgets/question_activity_card.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/pages/clam_business/widgets/review_card.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../core/utils/time_parser.dart';
import '../../widgets/app_skeleton.dart';
import '../../widgets/custom_text_field.dart';

class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late RecentActivityController ctrl = Get.find<RecentActivityController>();

  int _activeTabIndex = 0;

  final _tabTypes = const [
    RecentActivityType.questions,
    RecentActivityType.answered,
    RecentActivityType.reviews,
    RecentActivityType.business,
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchActivities(RecentActivityType.questions);
    });

    tabController.addListener(() {
      if (tabController.indexIsChanging ||
          tabController.animation?.value == tabController.index) {
        if (tabController.index != _activeTabIndex) {
          setState(() => _activeTabIndex = tabController.index);
          ctrl.changeType(_tabTypes[tabController.index]);
        }
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: "Recent Activity"),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      hintText: "Recent Activity...",
                      borderColor: colorScheme.outline,
                      suffixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Recent Activity",
                      style: AppTextStyle.textXl(
                        color: colorScheme.onSurface,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Track your recent activity",
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurface,
                  indicatorColor: colorScheme.primary,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Question"),
                    Tab(text: "Answered"),
                    Tab(text: "Reviews"),
                    Tab(text: "List"),
                  ],
                ),
                color: colorScheme.surface,
              ),
            ),
          ];
        },
        body: GetBuilder<RecentActivityController>(
          builder: (ctrl) {
            return TabBarView(
              controller: tabController,
              children: [
                _buildTabWrapper(
                  type: RecentActivityType.questions,
                  isEmpty: ctrl.questions.isEmpty,
                  onRefresh: () =>
                      ctrl.fetchActivities(RecentActivityType.questions),
                  onLoadMore: () =>
                      ctrl.loadMore(RecentActivityType.questions),
                  itemCount: ctrl.questions.length,
                  hasNext: ctrl.hasNextPage(RecentActivityType.questions),
                  isLoading:
                  ctrl.isLoadingType(RecentActivityType.questions),
                  itemBuilder: (index) {
                    final item = ctrl.questions[index];
                    return buildQuestionActivityCard(
                      context: context,
                      name: item.name,
                      question: item.question,
                      category: item.category,
                      imageUrl: item.avatar,
                      likeCount: item.likes,
                      commentCount: item.comments,
                      date: DateParserHelper.toFriendlyDate(item.date),
                    );
                  },
                ),
                _buildTabWrapper(
                  type: RecentActivityType.answered,
                  isEmpty: ctrl.answered.isEmpty,
                  onRefresh: () =>
                      ctrl.fetchActivities(RecentActivityType.answered),
                  onLoadMore: () =>
                      ctrl.loadMore(RecentActivityType.answered),
                  itemCount: ctrl.answered.length,
                  hasNext: ctrl.hasNextPage(RecentActivityType.answered),
                  isLoading:
                  ctrl.isLoadingType(RecentActivityType.answered),
                  itemBuilder: (index) {
                    final item = ctrl.answered[index];
                    return buildAnswerActivityCard(
                      context: context,
                      question: item.question,
                      answer: item.answer,
                      timestamp: formatUtcToLocalTime(item.time),
                      imageUrl: item.questionAuthorAvatar,
                    );
                  },
                ),
                _buildTabWrapper(
                  type: RecentActivityType.reviews,
                  isEmpty: ctrl.reviews.isEmpty,
                  onRefresh: () =>
                      ctrl.fetchActivities(RecentActivityType.reviews),
                  onLoadMore: () =>
                      ctrl.loadMore(RecentActivityType.reviews),
                  itemCount: ctrl.reviews.length,
                  hasNext: ctrl.hasNextPage(RecentActivityType.reviews),
                  isLoading: ctrl.isLoadingType(RecentActivityType.reviews),
                  itemBuilder: (index) {
                    final item = ctrl.reviews[index];
                    return ReviewCard(
                      name: item.name,
                      businessName: item.business,
                      reviewText: item.review,
                      imageUrl: item.businessLogo,
                      rating: item.rating,
                    );
                  },
                ),
                _buildTabWrapper(
                  type: RecentActivityType.business,
                  isEmpty: ctrl.businesses.isEmpty,
                  onRefresh: () =>
                      ctrl.fetchActivities(RecentActivityType.business),
                  onLoadMore: () =>
                      ctrl.loadMore(RecentActivityType.business),
                  itemCount: ctrl.businesses.length,
                  hasNext: ctrl.hasNextPage(RecentActivityType.business),
                  isLoading:
                  ctrl.isLoadingType(RecentActivityType.business),
                  itemBuilder: (index) {
                    final item = ctrl.businesses[index];
                    return buildBusinessActivityCard(
                      context: context,
                      businessName: item.businessName,
                      category: item.category,
                      imageUrl: item.businessLogo,
                      lastVisited:
                      DateParserHelper.toFriendlyDate(item.date),
                      onMenuTap: () {},
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // REUSABLE TAB WRAPPER (Updated with PageStorageKey)
  // ═══════════════════════════════════════
  Widget _buildTabWrapper({
    required RecentActivityType type,
    required bool isEmpty,
    required int itemCount,
    required bool hasNext,
    required bool isLoading,
    required Future<void> Function() onRefresh,
    required VoidCallback onLoadMore,
    required Widget Function(int index) itemBuilder,
  }) {
    if (isLoading && isEmpty) return AppSkeleton.list(context: context);
    if (isEmpty) return const Center(child: Text("No items found"));

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!isLoading &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return true;
      },
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          // SOLUTION: Adding a PageStorageKey for each tab
          key: PageStorageKey<String>(type.toString()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index == itemCount) {
                      return isLoading
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                          : const SizedBox(height: 60);
                    }
                    return itemBuilder(index);
                  },
                  childCount: itemCount + (hasNext ? 1 : 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;

  const _TabBarDelegate(this.tabBar, {required this.color});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}