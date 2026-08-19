import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/services/connectivity/connectivity_service.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
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
import 'package:loci/shared/widgets/feed/post_comment_bottom_sheet.dart';
import 'package:loci/shared/widgets/feed/post_card.dart';
import 'package:loci/shared/models/post_card_view_model.dart';

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

  void _dismissMentionUi() {
    FocusManager.instance.primaryFocus?.unfocus();
    _activeMentionPostId.value = null;
    _searchCtrl.reset();
  }

  void _onMentionChanged(String postId, String query) {
    _claimMentionSession(postId, resetIfSwitching: true);
    _searchCtrl.onSearchChanged(query);
  }

  void _onMentionFocusChanged(String postId, bool focused) {
    // Unfocus on the same card must NOT clear results (scroll/tap suggestions).
    // Focusing a *different* card switches the session and drops old results.
    if (!focused) return;
    _claimMentionSession(postId, resetIfSwitching: true);
  }

  /// Exactly one poll card owns mention search at a time.
  void _claimMentionSession(String postId, {required bool resetIfSwitching}) {
    final previous = _activeMentionPostId.value;
    if (resetIfSwitching && previous != null && previous != postId) {
      _searchCtrl.reset();
    }
    _activeMentionPostId.value = postId;
  }

  void _onMentionBusinessSelected(String postId, BrowseBusinessModel business) {
    // Keep this card active for Send; only clear the shared suggestion list.
    _searchCtrl.reset();
  }

  Future<void> _onMentionSubmit(
    String postId,
    String text,
    String image,
  ) async {
    // Keep the user on this post after submit (keyboard close + list rebuild
    // must not reset the home scroll to the top).
    final sc = questionListController.scrollController;
    final savedOffset = sc.hasClients ? sc.offset : null;

    _dismissMentionUi();

    final newOption = await _addPollOptionCtrl.addPollOption(
      questionId: postId,
      text: text,
      imageUrl: image.isNotEmpty ? image : null,
    );

    if (!mounted) return;
    _dismissMentionUi();

    if (newOption != null) {
      questionListController.appendPollOption(postId, newOption);
    } else if (_addPollOptionCtrl.errorMessage.value != null) {
      final message = _addPollOptionCtrl.errorMessage.value!;
      if (!message.toLowerCase().contains('already')) {
        SnackbarService.error(message);
      }
    } else {
      questionListController.fetchQuestions(isRefresh: true);
    }

    void restoreScroll() {
      if (!mounted || savedOffset == null || !sc.hasClients) return;
      final max = sc.position.maxScrollExtent;
      sc.jumpTo(savedOffset.clamp(0.0, max));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      restoreScroll();
      // Keyboard inset finishes collapsing a beat later — restore again.
      Future<void>.delayed(const Duration(milliseconds: 280), restoreScroll);
    });
  }

  void _showCommentSheet(String questionId) {
    _dismissMentionUi();
    PostCommentBottomSheet.showForHomeQuestion(
      context,
      questionId: questionId,
      commentController: _commentCtrl,
      currentUserImage: _authController.userModel?.avatar ?? '',
    );
  }

  void _showAllPolls(PostCardViewModel viewModel) {
    _dismissMentionUi();
    PollBottomSheet.show(
      context,
      viewModel,
      currentUserId: _authController.userModel?.id,
      onVote: (optionId) => _onVote(viewModel.postId, optionId),
    );
  }

  Future<void> _onVote(String questionId, String optionId) async {
    _dismissMentionUi();
    final success = await _voteCtrl.submitVote(
      questionId: questionId,
      optionId: optionId,
    );

    if (!mounted) return;
    _dismissMentionUi();

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
      resizeToAvoidBottomInset: true,
      body: AdaptiveRefresh(
        onRefresh: () async {
          await Future.wait([
            questionListController.fetchQuestions(isRefresh: true),
            _adListController.fetchAds(isRefresh: true),
          ]);
        },
        child: SingleChildScrollView(
          controller: questionListController.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom > 0
                ? MediaQuery.viewInsetsOf(context).bottom + 80
                : 20,
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // --- 1️⃣ Carousel Slider (live ads from /ads) ---
              Obx(() {
                final adCtrl = _adListController;
                if (adCtrl.showInitialShimmer) {
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
                              const ActiveRafflesPage(),
                              title: 'Active Raffles',
                            );
                            break;

                          case "Communities":
                            // Full-screen section on the root navigator: single
                            // app bar + back, no bottom nav (not a primary tab).
                            Get.toNamed(AppRoutes.allCommunity);
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

                if (controller.showInitialShimmer) {
                  return const HomeShimmer();
                }
                if (controller.questions.isEmpty && ConnectivityService.isCurrentOffline) {
                  return ErrorStateWidget.noInternet(
                    onRetry: () => controller.fetchQuestions(isRefresh: true),
                  );
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
                  searchCtrl.isPaginationLoading.value;
                }
                // Live session avatar — updates home cards after profile pic change.
                final me = _authController.userModelRx.value;
                final avatarRev = _authController.avatarRevision.value;
                final myAvatar = me?.avatar ?? '';
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
                      key: ValueKey('home-post-${question.id}'),
                      viewModel: viewModel,
                      onLikeTap: (postId) {
                        _dismissMentionUi();
                        _likeCtrl.toggleLike(postId);
                      },
                      onCommentTap: (postId) => _showCommentSheet(postId),
                      onClickPoll: (_) => _showAllPolls(viewModel),
                      onMentionChanged: _onMentionChanged,
                      onMentionSubmit: _onMentionSubmit,
                      onMentionBusinessSelected: _onMentionBusinessSelected,
                      onMentionFocusChanged: _onMentionFocusChanged,
                      mentionSuggestions: isActive
                          ? List<BrowseBusinessModel>.of(searchCtrl.businesses)
                          : const [],
                      isMentionLoading: isActive && searchCtrl.isLoading,
                      mentionSearchDone: isActive && searchCtrl.searchDone,
                      isMentionActive: isActive,
                      mentionHasNextPage: isActive && searchCtrl.hasNextPage,
                      mentionIsPaginationLoading:
                          isActive && searchCtrl.isPaginationLoading.value,
                      onMentionLoadMore: isActive
                          ? () => searchCtrl.loadNextPage()
                          : null,
                      currentUserImage: myAvatar,
                      currentUserId: me?.id,
                      avatarRevision: avatarRev,
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
