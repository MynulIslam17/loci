import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/recent_activity.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/features/browse_business/presentation/controllers/remove_saved_business_controller.dart';
import 'package:loci/features/recent_activity/presentation/controllers/recent_activity_controller.dart';
import 'package:loci/features/recent_activity/presentation/widgets/answer_activity_card.dart';
import 'package:loci/features/recent_activity/presentation/widgets/business_activity_card.dart';
import 'package:loci/features/recent_activity/presentation/widgets/question_activity_card.dart';
import 'package:loci/features/recent_activity/presentation/widgets/recent_activity_shimmer.dart';
import 'package:loci/features/recent_activity/presentation/widgets/review_activity_card.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';

class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final RecentActivityController _ctrl;
  late final RemoveSavedBusinessController _removeCtrl;
  final _searchController = TextEditingController();

  static const _tabTypes = [
    RecentActivityType.questions,
    RecentActivityType.answered,
    RecentActivityType.reviews,
    RecentActivityType.business,
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<RecentActivityController>();
    _removeCtrl = Get.find<RemoveSavedBusinessController>();
    _tabController = TabController(length: _tabTypes.length, vsync: this);

    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.ensureLoaded(_tabTypes[_tabController.index]);
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _ctrl.ensureLoaded(_tabTypes[_tabController.index]);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: 'Recent Activity'),
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
                      controller: _searchController,
                      hintText: 'Search activity...',
                      borderColor: colorScheme.outline,
                      showClearButton: true,
                      suffixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Recent Activity',
                      style: AppTextStyle.textXl(
                        color: colorScheme.onSurface,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track your questions, answers, reviews and saved businesses',
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
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurface,
                  indicatorColor: colorScheme.primary,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Questions'),
                    Tab(text: 'Answered'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Saved'),
                  ],
                ),
                color: colorScheme.surface,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _RecentActivityTab(
              type: RecentActivityType.questions,
              emptyState: const EmptyState(
                icon: Icons.help_outline_rounded,
                title: 'No questions yet',
                subtitle: 'Questions you post will show up here.',
              ),
              itemBuilder: (context, index) {
                final item = _ctrl.questions[index];
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
            _RecentActivityTab(
              type: RecentActivityType.answered,
              emptyState: const EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No answers yet',
                subtitle: 'Answers you give on questions will appear here.',
              ),
              itemBuilder: (context, index) {
                final item = _ctrl.answered[index];
                return buildAnswerActivityCard(
                  context: context,
                  question: item.question,
                  answer: item.answer,
                  timestamp: formatUtcToLocalTime(item.time),
                  imageUrl: item.questionAuthorAvatar,
                );
              },
            ),
            _RecentActivityTab(
              type: RecentActivityType.reviews,
              emptyState: const EmptyState(
                icon: Icons.star_outline_rounded,
                title: 'No reviews yet',
                subtitle: 'Reviews you leave for businesses will show here.',
              ),
              itemBuilder: (context, index) {
                final item = _ctrl.reviews[index];
                return buildReviewActivityCard(
                  context: context,
                  name: item.name,
                  businessName: item.business,
                  reviewText: item.review,
                  imageUrl: item.businessLogo,
                  rating: item.rating.toDouble(),
                );
              },
            ),
            _RecentActivityTab(
              type: RecentActivityType.business,
              emptyState: const EmptyState(
                icon: Icons.storefront_outlined,
                title: 'No saved businesses',
                subtitle: 'Businesses you save will appear in this list.',
              ),
              itemBuilder: (context, index) {
                final item = _ctrl.businesses[index];
                final visitedLabel = item.date != null
                    ? 'Visited ${DateParserHelper.toFriendlyDate(item.date)}'
                    : 'Not visited yet';

                return buildBusinessActivityCard(
                  context: context,
                  businessName: item.businessName,
                  category: item.category,
                  imageUrl: item.businessLogo,
                  lastVisited: visitedLabel,
                  isDeleting: _removeCtrl.isLoading(item.id),
                  onDelete: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remove business?'),
                        content: Text(
                          'Remove "${item.businessName}" from your saved list?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;

                    final success = await _removeCtrl.removeBusiness(item.id);
                    if (success) _ctrl.removeBusiness(item.id);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityTab extends StatefulWidget {
  const _RecentActivityTab({
    required this.type,
    required this.emptyState,
    required this.itemBuilder,
  });

  final RecentActivityType type;
  final EmptyState emptyState;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  State<_RecentActivityTab> createState() => _RecentActivityTabState();
}

class _RecentActivityTabState extends State<_RecentActivityTab>
    with AutomaticKeepAliveClientMixin {
  late final RecentActivityController _ctrl = Get.find<RecentActivityController>();
  late final RemoveSavedBusinessController _removeCtrl =
      Get.find<RemoveSavedBusinessController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final type = widget.type;
      final count = _ctrl.itemCount(type);
      final isInitialLoading = _ctrl.isInitialLoading(type);
      final isLoadingMore = _ctrl.isLoadingMore(type);
      final error = _ctrl.errorFor(type);
      final hasNext = _ctrl.hasNextPage(type);
      final hasFetched = _ctrl.hasFetched(type);

      // Rebuild business rows while a delete is in progress.
      if (type == RecentActivityType.business) {
        _removeCtrl.loadingId.value;
      }

      if (isInitialLoading && !hasFetched) {
        return RecentActivityShimmer.forType(type, context: context);
      }

      if (error != null && count == 0) {
        return ErrorStateWidget(
          message: error,
          onRetry: () => _ctrl.reload(type),
        );
      }

      if (count == 0 && hasFetched) {
        return RefreshIndicator(
          onRefresh: () => _ctrl.reload(type),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [widget.emptyState],
          ),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!isInitialLoading &&
              !isLoadingMore &&
              !_ctrl.isRefreshing(type) &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
            _ctrl.loadMore(type);
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () => _ctrl.reload(type),
          child: ListView.builder(
            key: PageStorageKey<String>('recent_activity_${type.name}'),
            padding: const EdgeInsets.all(12),
            itemCount: count + (hasNext ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= count) {
                return isLoadingMore
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const SizedBox(height: 60);
              }
              return widget.itemBuilder(context, index);
            },
          ),
        ),
      );
    });
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar, {required this.color});

  final TabBar tabBar;
  final Color color;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: color, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
