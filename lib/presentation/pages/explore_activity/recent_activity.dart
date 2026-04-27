import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/recent_activity.dart';
import 'package:loci/presentation/controllers/recent_activity/recent_activity_controller.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/pages/clam_business/widgets/review_card.dart';

import '../../../core/theme/theme_extention.dart';
import '../../../data/models/recent_activity/answer_activity_model.dart';
import '../../../data/models/recent_activity/business_activity_model.dart';
import '../../../data/models/recent_activity/question_activity_model.dart';
import '../../../data/models/recent_activity/review_activity_model.dart';
import '../../widgets/custom_text_field.dart';
import '../home/widgets/expandable_text.dart';
import '../home/widgets/post_interaction_bar.dart';

class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late RecentActivityController controller;

  final _tabTypes = const [
    RecentActivityType.questions,
    RecentActivityType.answered,
    RecentActivityType.reviews,
    RecentActivityType.businesses,
  ];

  @override
  void initState() {
    super.initState();

    controller = Get.put(RecentActivityController());
    tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchActivities(RecentActivityType.questions);
    });

    tabController.addListener(() {
      if (!tabController.indexIsChanging) return;
      controller.changeType(_tabTypes[tabController.index]);
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
                      fontSize: 14,
                      textColor: colorScheme.onSurface,
                      hintTextColor: colorScheme.onSurfaceVariant,
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

            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              bottom: TabBar(
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
            ),
          ];
        },
        body: GetBuilder<RecentActivityController>(
          builder: (ctrl) {
            return TabBarView(
              controller: tabController,
              children: [
                 _buildQuestionList(context, ctrl),
                 _buildAnsweredList(context, ctrl),
                 _buildReviewList(context, ctrl),
                 _buildBusinessList(context, ctrl),

              ],
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // QUESTION TAB
  // ═══════════════════════════════════════
  // ONLY CHANGED PARTS ARE LIST BINDINGS
// UI IS EXACT SAME

  Widget _buildQuestionList(
      BuildContext context, RecentActivityController ctrl) {
    final colorScheme = context.colorScheme;
    final items = ctrl.questions;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          color: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name),
                Text(item.question),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════
  // ANSWERED TAB
  // ═══════════════════════════════════════
  Widget _buildAnsweredList(
      BuildContext context, RecentActivityController ctrl) {

    final items = ctrl.answered;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];

        return buildAnswerActivityCard(
          context: context,
          question: item.question,
          answer: item.answer,
          timestamp: item.time,
        );
      },
    );
  }

  // ═══════════════════════════════════════
  // REVIEW TAB
  // ═══════════════════════════════════════
  Widget _buildReviewList(
      BuildContext context, RecentActivityController ctrl) {

    final items = ctrl.reviews;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];

        return ReviewCard(
          name: item.name,
          businessName: item.business,
          reviewText: item.review,
          imageUrl: "",
        );
      },
    );
  }

  // ═══════════════════════════════════════
  // BUSINESS TAB
  // ═══════════════════════════════════════
  Widget _buildBusinessList(
      BuildContext context, RecentActivityController ctrl) {

    final items = ctrl.businesses;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];

        return ListTile(
          title: Text(item.businessName),
          subtitle: Text("${item.category} | ${item.lastVisited}"),
        );
      },
    );
  }

  // ═══════════════════════════════════════
  // SKELETON
  // ═══════════════════════════════════════
  Widget _buildSkeleton() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildAnswerActivityCard({
    required BuildContext context,
    required String question,
    required String answer,
    required String timestamp,
  }) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question),
            const SizedBox(height: 8),
            Text(answer),
            const SizedBox(height: 8),
            Text(timestamp),
          ],
        ),
      ),
    );
  }
}