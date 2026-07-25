import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/home/data/models/carousel_data.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/home/domain/services/home_service.dart';
import 'package:loci/features/community/presentation/controllers/search_business_controller.dart';
import 'package:loci/features/home/presentation/controllers/ad_list_controller.dart';
import 'package:loci/features/home/presentation/controllers/home_add_poll_option_controller.dart';
import 'package:loci/features/home/presentation/controllers/home_comment_controller.dart';
import 'package:loci/features/home/presentation/controllers/home_like_controller.dart';
import 'package:loci/features/home/presentation/controllers/home_vote_controller.dart';
import 'package:loci/features/home/presentation/widgets/custom_carousel.dart';
import 'package:loci/features/home/presentation/widgets/carousel_fallback_banner.dart';
import 'package:loci/shared/widgets/feed/post_input_field.dart';
import 'package:loci/features/home/presentation/widgets/banner_shimmer.dart';
import 'package:loci/features/home/presentation/widgets/home_shimmer.dart';
import 'package:loci/features/raffles/presentation/pages/active_raffles_screen.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:loci/shared/widgets/pagination_loading.dart';
import 'package:loci/gen/assets.gen.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/home/presentation/controllers/post_question_controller.dart';
import 'package:loci/features/home/presentation/controllers/question_list_controller.dart';
import 'package:loci/features/main_nav/presentation/controllers/nav_controller.dart';
import 'package:loci/shared/widgets/feed/poll_bottom_sheet.dart';
import 'package:loci/shared/widgets/feed/post_comment_section.dart';
import 'package:loci/shared/widgets/feed/post_card.dart';
import 'package:loci/shared/models/post_card_view_model.dart';
import 'home_navigator.dart';

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
  final RxnString _activeMentionPostId = RxnString();

  //-- Activity row data ---
  final List<Map<String, dynamic>> activity = [
    {"name": "Communities", "icon": Assets.icons.comunity},
    {"name": "Events", "icon": Assets.icons.event1},
    {"name": "Raffles", "icon": Assets.icons.ticket},
  ];

  @override
  void initState() {
    super.initState();
    final homeService = Get.find<HomeService>();
    _searchCtrl = Get.put(
      SearchBusinessController(Get.find<CommunityService>()),
      tag: 'home',
    );
    _addPollOptionCtrl = Get.put(
      HomeAddPollOptionController(homeService),
      tag: 'home',
    );
    _voteCtrl = Get.put(HomeVoteController(homeService), tag: 'home');
    _likeCtrl = Get.put(HomeLikeController(homeService), tag: 'home');
    _commentCtrl = Get.put(HomeCommentController(homeService), tag: 'home');
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
    _activeMentionPostId.value = postId;
    _searchCtrl.onSearchChanged(query);
  }

  void _onMentionBusinessSelected(String postId, BrowseBusinessModel business) {
    _activeMentionPostId.value = null;
    _searchCtrl.reset();
  }

  Future<void> _onMentionSubmit(
    String postId,
    String text,
    String image,
  ) async {
    _activeMentionPostId.value = null;
    _searchCtrl.reset();

    final newOption = await _addPollOptionCtrl.addPollOption(
      questionId: postId,
      text: text,
      imageUrl: image.isNotEmpty ? image : null,
    );

    if (newOption != null) {
      questionListController.appendPollOption(postId, newOption);
    } else if (_addPollOptionCtrl.errorMessage.value != null) {
      final message = _addPollOptionCtrl.errorMessage.value!;
      // Adding an option that already exists isn't a real failure — the input
      // is already cleared, so silently ignore it (no snackbar). Only surface
      // genuine errors.
      if (!message.toLowerCase().contains('already')) {
        SnackbarService.error(message);
      }
    } else {
      // Request succeeded but the response shape was unrecognized —
      // refresh so the new option still shows up.
      questionListController.fetchQuestions(isRefresh: true);
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
      builder: (_) => Obx(
        () => PostCommentSection(
          comments: _commentCtrl.comments.toList(),
          controller: inputController,
          scrollController: _commentCtrl.scrollController,
          paginationLoading: _commentCtrl.isPaginating.value,
          currentUserImage: _authController.userModel?.avatar ?? '',
          isLoading: _commentCtrl.isLoading.value,
          isSending: _commentCtrl.isPosting.value,
          onSendTap: (text) =>
              _commentCtrl.postComment(content: text, questionId: questionId),
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
      SnackbarService.error(_voteCtrl.errorMessage.value ?? 'Vote failed');
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
              Obx(() {
                final adCtrl = _adListController;
                if (adCtrl.isLoading.value && adCtrl.ads.isEmpty) {
                  return const BannerShimmer();
                }
                // No ads to show: render a purpose-built branded banner rather
                // than forcing the app logo through the image carousel. The
                // copy adapts to whether the request errored (server down) or
                // simply came back empty.
                if (adCtrl.ads.isEmpty) {
                  return CarouselFallbackBanner(
                    isError: adCtrl.errorMessage.value != null,
                    onRetry: () => adCtrl.fetchAds(showErrorToast: false),
                  );
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
                return CustomCarousel(carouselData: items);
              }),
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
                  categories: BusinessCategory.values
                      .map((e) => e.label)
                      .toList(),
                  onSubmit: (text, category, type) async {
                    final success = await postQuestionController.postQuestion(
                      content: text,
                      category: category,
                      type: type.toJson,
                    );

                    if (success) {
                      questionListController.fetchQuestions(isRefresh: true);
                    } else {
                      SnackbarService.error(
                        postQuestionController.errorMessage.value ??
                            "Something went wrong",
                      );
                    }
                  },
                ),
              ),

              Obx(() {
                final controller = questionListController;

                if (controller.isLoading.value) {
                  return const HomeShimmer();
                }
                if (controller.errorMessage.value != null &&
                    controller.questions.isEmpty) {
                  return ErrorStateWidget(
                    message: controller.errorMessage.value!,
                    onRetry: () => controller.fetchQuestions(isRefresh: true),
                  );
                }
                if (controller.questions.isEmpty) {
                  return EmptyState(
                    icon: Icons.help_outline_rounded,
                    title: "No questions yet",
                    subtitle: "Be the first to ask something!",
                  );
                }
                final activeMentionId = _activeMentionPostId.value;
                final searchCtrl = _searchCtrl;
                // Touch the search observables synchronously so this Obx
                // subscribes to them. They're otherwise only read inside
                // itemBuilder, which runs during layout — after this builder
                // returns — so GetX would never rebuild when results arrive
                // (only a hot reload's full rebuild would show them).
                if (activeMentionId != null) {
                  searchCtrl.status.value;
                  searchCtrl.businesses.length;
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount:
                      controller.questions.length +
                      (controller.isPaginationLoading.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.questions.length) {
                      return PaginationLoader();
                    }
                    final question = controller.questions[index];
                    final isActive = activeMentionId == question.id;
                    final viewModel = PostCardViewModel.fromQuestion(question);
                    return PostCardWidget(
                      viewModel: viewModel,
                      onLikeTap: (postId) => _likeCtrl.toggleLike(postId),
                      onCommentTap: (postId) => _showCommentSheet(postId),
                      onClickPoll: (_) => _showAllPolls(viewModel),
                      onMentionChanged: _onMentionChanged,
                      onMentionSubmit: _onMentionSubmit,
                      onMentionBusinessSelected: _onMentionBusinessSelected,
                      mentionSuggestions: isActive
                          ? searchCtrl.businesses
                          : const [],
                      isMentionLoading: isActive && searchCtrl.isLoading,
                      mentionSearchDone: isActive && searchCtrl.searchDone,
                      currentUserImage: _authController.userModel?.avatar ?? "",
                      currentUserId: _authController.userModel?.id,
                    );
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
