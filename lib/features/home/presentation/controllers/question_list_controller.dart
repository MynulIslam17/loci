import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/core/services/connectivity_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/home/data/models/poll_option_model.dart';
import 'package:loci/features/home/data/models/question_model.dart';
import 'package:loci/features/home/data/models/voter_model.dart';
import 'package:loci/features/home/domain/services/home_service.dart';

class QuestionListController extends GetxController {
  QuestionListController(this._service, [HiveStorageService? storage])
      : _storage = storage ??
            (Get.isRegistered<HiveStorageService>()
                ? Get.find<HiveStorageService>()
                : null);

  final HomeService _service;
  final HiveStorageService? _storage;
  StreamSubscription<void>? _reconnectSub;

  final Map<String, QuestionModel> _questionMap = {};
  final List<String> _questionIds = [];
  final Map<String, String> _votedOptionIds = {};

  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final errorMessage = RxnString();
  final questions = <QuestionModel>[].obs;
  final _meta = Rxn<PaginationMeta>();
  int _currentPage = 1;

  final ScrollController scrollController = ScrollController();

  RxBool get isLoading => _fetch.initialLoading;
  RxBool get isPaginationLoading => _fetch.loadingMore;
  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;

  bool get hasMore => _meta.value?.hasNextPage ?? false;

  String? votedOptionId(String questionId) => _votedOptionIds[questionId];

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);

    // Frame-0 instant load from Hive cache
    if (_storage != null) {
      final cached = _storage.getFeedList('home_feed_questions');
      if (cached.isNotEmpty) {
        final models = cached
            .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _append(models);
        _syncQuestions();
        _fetch.endFirstPage(markFetched: true);
      }
    }

    if (Get.isRegistered<ConnectivityService>()) {
      _reconnectSub = Get.find<ConnectivityService>().onReconnect.listen((_) {
        fetchQuestions(isRefresh: true);
      });
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      fetchMore();
    }
  }

  @override
  void onClose() {
    _reconnectSub?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _syncQuestions() {
    questions.assignAll(
      _questionIds
          .map((id) => _questionMap[id])
          .whereType<QuestionModel>()
          .toList(),
    );
  }

  Future<void> fetchQuestions({bool isRefresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    // Fast Offline Guard: short-circuit immediately if offline
    if (ConnectivityService.isCurrentOffline) {
      _fetch.endFirstPage(markFetched: true);
      return;
    }

    if (isRefresh) {
      _currentPage = 1;
    }

    _fetch.beginFirstPage(isRefresh: isRefresh);
    errorMessage.value = null;

    try {
      final result = await _service.getQuestions(page: _currentPage, limit: 20);
      if (isRefresh || _currentPage == 1) {
        _questionIds.clear();
        _questionMap.clear();
      }
      _append(result.data);
      _meta.value = result.meta;
      _syncQuestions();
      _fetch.endFirstPage();

      if (_currentPage == 1 && _storage != null && result.data.isNotEmpty) {
        _storage.saveFeedList(
          'home_feed_questions',
          result.data.map((q) => q.toJson()).toList(),
        );
      }
    } catch (e) {
      if (questions.isEmpty) {
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
      _fetch.endFirstPage(markFetched: hasFetched || questions.isNotEmpty);
    }
  }

  Future<void> fetchMore() async {
    if (!hasMore || isPaginationLoading.value || isInitialLoading || isRefreshing) {
      return;
    }

    // Fast Offline Guard: do not attempt pagination when offline
    if (ConnectivityService.isCurrentOffline) return;

    try {
      _fetch.beginLoadMore();
      _currentPage++;

      final result = await _service.getQuestions(page: _currentPage, limit: 20);
      _append(result.data);
      _meta.value = result.meta;
      _syncQuestions();
    } catch (e) {
      _currentPage--;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _fetch.endLoadMore();
    }
  }

  void prepend(QuestionModel question) {
    _questionMap[question.id] = question;
    _questionIds.insert(0, question.id);
    _syncQuestions();
  }

  void incrementCommentCount(String questionId) {
    final question = _questionMap[questionId];
    if (question == null) return;
    _questionMap[questionId] = question.copyWith(
      commentCount: question.commentCount + 1,
    );
    _syncQuestions();
  }

  void toggleLikeLocally(String questionId) {
    final question = _questionMap[questionId];
    if (question == null) return;
    _questionMap[questionId] = question.copyWith(
      isLiked: !question.isLiked,
      likeCount: question.isLiked
          ? (question.likeCount - 1).clamp(0, question.likeCount)
          : question.likeCount + 1,
    );
    _syncQuestions();
  }

  void appendPollOption(String questionId, PollOptionModel option) {
    final question = _questionMap[questionId];
    if (question == null) return;
    _questionMap[questionId] = question.copyWith(
      options: [...question.options, option],
    );
    _syncQuestions();
  }

  void updatePollVote(
    String questionId,
    String newOptionId, {
    required String userId,
    required String userName,
    required String userAvatar,
  }) {
    final question = _questionMap[questionId];
    if (question == null) return;

    // First check our local tracking map; if absent, scan voters lists
    // (handles the case where the app started fresh with server-side votes)
    String? previousOptionId = _votedOptionIds[questionId];
    if (previousOptionId == null && userId.isNotEmpty) {
      for (final opt in question.options) {
        if (opt.voters.any((v) => v.userId == userId)) {
          previousOptionId = opt.optionId;
          break;
        }
      }
    }

    // Nothing to do — user is voting for the same option again
    if (previousOptionId == newOptionId) return;

    final isChangingVote = previousOptionId != null;
    final newVoter = VoterModel(
      userId: userId,
      name: userName,
      avatar: userAvatar,
    );

    // Total votes only increases on a fresh vote, not a vote change
    final newTotalVotes = isChangingVote
        ? question.totalVotes
        : question.totalVotes + 1;

    final updatedOptions = question.options.map((opt) {
      int newVoteCount = opt.voteCount;
      List<VoterModel> newVoters = opt.voters;

      if (opt.optionId == newOptionId) {
        // Guard against duplicates — only add if user not already a voter
        if (!newVoters.any((v) => v.userId == userId)) {
          newVoteCount = opt.voteCount + 1;
          newVoters = [...opt.voters, newVoter];
        }
      } else if (isChangingVote && opt.optionId == previousOptionId) {
        // Remove the user from the previous option
        newVoteCount = (opt.voteCount - 1).clamp(0, opt.voteCount);
        newVoters = opt.voters.where((v) => v.userId != userId).toList();
      }

      final newPercentage = newTotalVotes > 0
          ? ((newVoteCount / newTotalVotes) * 100).round()
          : 0;

      return opt.copyWith(
        voteCount: newVoteCount,
        percentage: newPercentage,
        voters: newVoters,
      );
    }).toList();

    _questionMap[questionId] = question.copyWith(
      options: updatedOptions,
      totalVotes: newTotalVotes,
    );
    _votedOptionIds[questionId] = newOptionId;
    _syncQuestions();
  }

  void _append(List<QuestionModel> items) {
    for (final item in items) {
      _questionMap[item.id] = item;
      if (!_questionIds.contains(item.id)) _questionIds.add(item.id);
    }
  }
}
