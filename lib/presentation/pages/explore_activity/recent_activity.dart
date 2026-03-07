import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/review_card.dart';

import '../../../core/theme/theme_extention.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/expandable_text.dart';
import '../../widgets/post_interaction_bar.dart';

/// RecentActivity Screen
/// Shows four tabs: Question, Answered, Reviews, List
/// Sticky TabBar with NestedScrollView
class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 4 tabs
    tabController = TabController(length: 4, vsync: this);
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
            /// 1️⃣ Search + Title (Scrolls away)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Field
                    CustomTextField(
                      hintText: "Recent Activity...",
                      borderColor: colorScheme.outline,
                      fontSize: 14,
                      textColor: colorScheme.onSurface,
                      hintTextColor: colorScheme.onSurfaceVariant,
                      suffixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 14),

                    // Main Title
                    Text(
                      "Recent Activity",
                      style: AppTextStyle.textXl(
                        color: colorScheme.onSurface,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Subtitle
                    Text(
                      "Track your recent activity",
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            /// 2️⃣ Sticky TabBar (Pinned)
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
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
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Question"),
                    Tab(text: "Answered"),
                    Tab(text: "Reviews"),
                    Tab(text: "List"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: [
            _buildTabBody(questionList()),  // Questions
            _buildTabBody(answeredList()),  // Answered
            _buildTabBody(reviewList()),    // Reviews
            _buildTabBody(listItems()),     // List
          ],
        ),
      ),
    );
  }

  /// Wraps each tab's list in CustomScrollView to fix "half scrolled" issue
  Widget _buildTabBody(Widget listWidget) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          slivers: [
            // Space for pinned TabBar
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            // Actual content of the tab
            SliverToBoxAdapter(child: listWidget),
          ],
        );
      },
    );
  }

  // =======================
  // QUESTION LIST
  // =======================
  Widget questionList() {
    final colorScheme = context.colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Disable internal scroll
      itemBuilder: (context, index) {
        return Card(
          color: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + Name + Category
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomCachedImage(
                      height: 50,
                      width: 50,
                      imageUrl: "assets/images/finedine.png",
                      isCircle: true,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Alexandra Broke",
                                  style: AppTextStyle.textMd(weight: FontWeight.w600, color: colorScheme.onSurface),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "In Non Profits",
                                style: AppTextStyle.textXs(weight: FontWeight.w600, color: colorScheme.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text("04/09/25", style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
                              const SizedBox(width: 12),
                              Text("05:36:12", style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ExpandableText(text: "Any food that you liked recently? " * 5, trimLines: 2),
                const SizedBox(height: 12),
                PostInteractionBar(likes: "200", comments: "45"),
              ],
            ),
          ),
        );
      },
    );
  }

  // =======================
  // ANSWERED LIST
  // =======================
  Widget answeredList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return buildAnswerActivityCard(
          context: context,
          question: "What is your favorite food?",
          answer: "I love sushi!",
          timestamp: "2 hours ago",
        );
      },
    );
  }

  // =======================
  // REVIEWS LIST
  // =======================
  Widget reviewList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return ReviewCard(
          name: "Alexandra Broke",
          businessName: "Non-Profit Organization",
          reviewText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
          imageUrl: "assets/images/finedine.png",
        );
      },
    );
  }

  // =======================
  // LIST ITEMS
  // =======================
  Widget listItems() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildAddToList(context),
    );
  }

  // -----------------------
  // Add-to-List Card
  // -----------------------
  Widget _buildAddToList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        color: colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              CustomCachedImage(height: 50, width: 50, imageUrl: "assets/images/finedine.png", isCircle: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Marland Clutch", style: AppTextStyle.textMd(weight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text("Local Services | 43 min ago", style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------
  // Answer Activity Card
  // -----------------------
  Widget buildAnswerActivityCard({
    required BuildContext context,
    required String question,
    required String answer,
    required String timestamp,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        color: colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question, style: AppTextStyle.textMd(weight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(answer, style: AppTextStyle.textSm(color: colorScheme.onSurface)),
              ),
              const SizedBox(height: 6),
              Text(timestamp, style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant.withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }
}