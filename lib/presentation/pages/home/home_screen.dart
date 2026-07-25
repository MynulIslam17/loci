import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/data/models/busniess/browse_business_model.dart';
import 'package:loci/data/models/carousel_data.dart';
import 'package:loci/presentation/controllers/community/search_business_controller.dart';
import 'package:loci/presentation/controllers/home/ad_list_controller.dart';
import 'package:loci/presentation/controllers/home/home_add_poll_option_controller.dart';
import 'package:loci/presentation/controllers/home/home_comment_controller.dart';
import 'package:loci/presentation/controllers/home/home_like_controller.dart';
import 'package:loci/presentation/controllers/home/home_vote_controller.dart';
import 'package:loci/presentation/pages/home/widgets/custom_carousel.dart';
import 'package:loci/presentation/pages/home/widgets/post_input_filed.dart';
import 'package:loci/presentation/pages/raffles/active_raffles_screen.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';
import 'package:loci/presentation/widgets/empty_state.dart';
import 'package:loci/presentation/widgets/pagination_loading.dart';
import '../../../gen/assets.gen.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../controllers/home/post_question_controller.dart';
import '../../controllers/home/question_list_controller.dart';
import '../../controllers/nav_controller.dart';
import '../communites/widgets/poll_bottom_sheet.dart';
import '../communites/widgets/post_comment_section.dart';
import '../communites/widgets/post_card.dart';
import '../communites/widgets/post_card_view_model.dart';
import 'home navigator.dart';
import 'widgets/home_shimmer.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final navController = Get.find<NavController>();
  final postQuestionController = Get.find<PostQuestionController>();
  final questionListController = Get.find<QuestionListController>();
  final _adListController = Get.find<AdListController>();
  final _authController = Get.find<AuthController>();

  // --- Search bar controls ---
  final TextEditingController _postController = TextEditingController();
  final FocusNode _postFocusNode = FocusNode();

  // --- Business mention ---
  late final SearchBusinessController _searchCtrl;
  late final HomeAddPollOptionController _addPollOptionCtrl;
  late final HomeVoteController _voteCtrl;
  late final HomeLikeController _likeCtrl;
  late final HomeCommentController _commentCtrl;
  String? _activeMentionPostId;

  //-- Fallback banner data (shown when /ads returns empty) ---
  final List<CarouselData> _fallbackBannerData = [
    CarouselData(
      placeName: "Barclay Prime",
      placeLocation: "237 S 18th St, Philadelphia, PA 19103",
      placeWeather: "30",
      placeImage: Assets.images.finedine.path,
    ),
    CarouselData(
      placeName: "Pizzaburge",
      placeLocation: "Dhanmondi, Dhaka",
      placeWeather: "44",
      placeImage: Assets.images.restu.path,
    ),
  ];

  //-- Activity row data ---
  final List<Map<String, dynamic>> activity = [
    {"name": "Communities", "icon": Assets.icons.comunity},
    {"name": "Events", "icon": Assets.icons.event1},
    {"name": "Raffles", "icon": Assets.icons.ticket},
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl = Get.put(SearchBusinessController(), tag: 'home');
    _addPollOptionCtrl = Get.put(HomeAddPollOptionController(), tag: 'home');
    _voteCtrl = Get.put(HomeVoteController(), tag: 'home');
    _likeCtrl = Get.put(HomeLikeController(), tag: 'home');
    _commentCtrl = Get.put(HomeCommentController(), tag: 'home');
    questionListController.fetchQuestions();
  }

  @override
  void dispose() {
    _postFocusNode.dispose();
    _postController.dispose();
    Get.delete<SearchBusinessController>(tag: 'home');
    Get.delete<HomeAddPollOptionController>(tag: 'home');
    Get.delete<HomeVoteController>(tag: 'home');
    Get.delete<HomeLikeController>(tag: 'home');
    Get.delete<HomeCommentController>(tag: 'home');
    super.dispose();
  }

  // ── Mention callbacks ────────────────────────────────────────────────────

  void _onMentionChanged(String postId, String query) {
    setState(() => _activeMentionPostId = postId);
    _searchCtrl.onSearchChanged(query);
  }

  void _onMentionBusinessSelected(String postId, BrowseBusinessModel business) {
    setState(() => _activeMentionPostId = null);
    _searchCtrl.reset();
  }

  Future<void> _onMentionSubmit(String postId, String text, String image) async {
    setState(() => _activeMentionPostId = null);
    _searchCtrl.reset();

    final updated = await _addPollOptionCtrl.addPollOption(
      questionId: postId,
      text: text,
      imageUrl: image.isNotEmpty ? image : null,
    );

    if (updated != null) {
      final newOption = updated.options.lastOrNull;
      if (newOption != null) {
        questionListController.appendPollOption(postId, newOption);
      }
    } else {
      SnackbarService.error(
        _addPollOptionCtrl.errorMessage ?? 'Failed to add poll option',
      );
    }
  }


  void _showCommentSheet(String questionId) {
    final inputController = TextEditingController();
    _commentCtrl.fetchComments(questionId: questionId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GetBuilder<HomeCommentController>(
        tag: 'home',
        builder: (ctrl) => PostCommentSection(
          comments: ctrl.comments,
          controller: inputController,
          scrollController: ctrl.scrollController,
          paginationLoading: ctrl.isPaginating,
          currentUserImage: _authController.userModel?.avatar ?? '',
          isLoading: ctrl.isLoading,
          isSending: ctrl.isPosting,
          onSendTap: (text) => ctrl.postComment(
            content: text,
            questionId: questionId,
          ),
        ),
      ),
    );
  }

  void _showAllPolls(PostCardViewModel viewModel) {
    PollBottomSheet.show(
      context,
      viewModel,
      currentUserId: _authController.userModel?.id,
      onVote: (optionId) => _onVote(viewModel.postId, optionId),
    );
  }

  Future<void> _onVote(String questionId, String optionId) async {
    final success = await _voteCtrl.submitVote(
      questionId: questionId,
      optionId: optionId,
    );

    if (success) {
      final user = _authController.userModel;
      questionListController.updatePollVote(
        questionId,
        optionId,
        userId: user?.id ?? '',
        userName: user?.name ?? '',
        userAvatar: user?.avatar ?? '',
      );
    } else {
      SnackbarService.error(_voteCtrl.errorMessage ?? 'Vote failed');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            questionListController.fetchQuestions(isRefresh: true),
            _adListController.fetchAds(),
          ]);
        },
        child: SingleChildScrollView(
          controller: questionListController.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          children: [
            const SizedBox(height: 16),

            // --- 1️⃣ Carousel Slider (live ads from /ads) ---
            GetBuilder<AdListController>(
              builder: (adCtrl) {
                if (adCtrl.isLoading && adCtrl.ads.isEmpty) {
                  return const _BannerShimmer();
                }
                final items = adCtrl.ads
                    .map(
                      (ad) => CarouselData(
                        placeName: ad.title,
                        placeLocation: ad.location.isNotEmpty
                            ? ad.location
                            : ad.businessName,
                        placeWeather: '',
                        placeImageUrl: ad.imageUrl,
                        linkUrl: ad.linkUrl,
                      ),
                    )
                    .toList();
                final data = items.isNotEmpty ? items : _fallbackBannerData;
                return CustomCarousel(carouselData: data);
              },
            ),
            const SizedBox(height: 20),

            // --- 2️⃣ Activity Row ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: activity.map((act) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      // Handle tap for each activity
                      switch (act["name"]) {
                        case "Raffles":
                          navController.openDrawerPage(
                            ActiveRafflesScreen(),
                            navigatorKey: ActiveRafflesScreen.navigatorKey,
                          );
                          break;

                        case "Communities":
                          HomeNavigator.push(AppRoutes.allCommunity);
                          break;

                        case "Events":
                          navController.changeIndex(2);
                          break;
                      }
                    },
                    child: SizedBox(
                      width: 100,
                      height: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(act["icon"]),
                          const SizedBox(height: 5),
                          Text(
                            act["name"],
                            style: AppTextStyle.textSm(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // --- 3️⃣ Post Input Field with Category Dropdown ---

            Padding(
              padding: const EdgeInsets.all(12),
              child: PostInputField(
                categories: BusinessCategory.values.map((e) => e.label).toList(),
                onSubmit: (text, category, type) async {
                  final success = await postQuestionController.postQuestion(
                    content: text,
                    category: category,
                    type: type.toJson,
                  );

                  if(success){
                    questionListController.fetchQuestions(isRefresh: true);
                  }else{
                    SnackbarService.error(postQuestionController.errorMessage ?? "Something went wrong");
                  }


                },
              ),
            ),

            GetBuilder<QuestionListController>(
              builder: (controller) {
                if (controller.isLoading) {
                  return const HomeShimmer();
                }
                if (controller.questions.isEmpty) {
                  return EmptyState(
                    icon: Icons.help_outline_rounded,
                    title: "No questions yet",
                    subtitle: "Be the first to ask something!",
                  );
                }
                return GetBuilder<SearchBusinessController>(
                  tag: 'home',
                  builder: (searchCtrl) => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: controller.questions.length +
                        (controller.isPaginationLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.questions.length) {
                        return PaginationLoader();
                      }
                      final question = controller.questions[index];
                      final isActive = _activeMentionPostId == question.id;
                      final viewModel = PostCardViewModel.fromQuestion(question);
                      return PostCardWidget(
                        viewModel: viewModel,
                        onLikeTap: (postId) => _likeCtrl.toggleLike(postId),
                        onCommentTap: (postId) => _showCommentSheet(postId),
                        onClickPoll: (_) => _showAllPolls(viewModel),
                        onMentionChanged: _onMentionChanged,
                        onMentionSubmit: _onMentionSubmit,
                        onMentionBusinessSelected: _onMentionBusinessSelected,
                        mentionSuggestions:
                            isActive ? searchCtrl.businesses : const [],
                        isMentionLoading: isActive && searchCtrl.isLoading,
                        mentionSearchDone: isActive && searchCtrl.searchDone,
                        currentUserImage: _authController.userModel?.avatar ?? "",
                        currentUserId: _authController.userModel?.id,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }


}

class _BannerShimmer extends StatelessWidget {
  const _BannerShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final cardWidth = MediaQuery.sizeOf(context).width * 0.85;

    return Column(
      children: [
        SizedBox(
          height: 208,
          child: Center(
            child: Container(
              width: cardWidth,
              height: 200,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  // Image area placeholder (fills the card)
                  Positioned.fill(
                    child: AppSkeleton.box(
                      width: double.infinity,
                      height: double.infinity,
                      radius: 15,
                    ),
                  ),
                  // Title + location row (mirrors CustomCarousel's bottom block)
                  Positioned(
                    bottom: 22,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppSkeleton.box(width: 160, height: 14, radius: 4),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            AppSkeleton.box(width: 14, height: 14, radius: 7),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AppSkeleton.box(
                                width: double.infinity,
                                height: 10,
                                radius: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Indicator dots placeholder
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSkeleton.box(width: 27, height: 8, radius: 4),
            const SizedBox(width: 6),
            AppSkeleton.box(width: 10, height: 8, radius: 4),
            const SizedBox(width: 6),
            AppSkeleton.box(width: 10, height: 8, radius: 4),
          ],
        ),
      ],
    );
  }
}
