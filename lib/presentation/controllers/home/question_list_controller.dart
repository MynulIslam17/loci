import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/common/paginatation_model.dart';
import 'package:loci/data/models/home/poll_option_model.dart';
import 'package:loci/data/models/home/question_model.dart';
import 'package:loci/data/models/home/question_list_response.dart';
import 'package:loci/data/models/home/voter_model.dart';

class QuestionListController extends GetxController {
  final Map<String, QuestionModel> _questionMap = {};
  final List<String> _questionIds = [];
  final Map<String, String> _votedOptionIds = {};

  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  PaginationMeta? _meta;
  int _currentPage = 1;

  final ScrollController scrollController = ScrollController();

  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _meta?.hasNextPage ?? false;

  String? votedOptionId(String questionId) => _votedOptionIds[questionId];

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      fetchMore();
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  List<QuestionModel> get questions => _questionIds
      .map((id) => _questionMap[id])
      .whereType<QuestionModel>()
      .toList();

  Future<void> fetchQuestions({bool isRefresh = false}) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _errorMessage = null;

      if (isRefresh) {
        _currentPage = 1;
        _questionIds.clear();
        _questionMap.clear();
      }

      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.questionList,
        queryParams: {'page': _currentPage, 'limit': 4},
      );

      if (response.isSuccess && response.body != null) {
        final result = QuestionListResponse.fromJson(response.body!);
        _append(result.data);
        _meta = result.meta;
      } else {
        _errorMessage = response.body?['message'] ?? 'Failed to load questions';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> fetchMore() async {
    if (!hasMore || _isPaginationLoading || _isLoading) return;

    try {
      _isPaginationLoading = true;
      _currentPage++;
      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.questionList,
        queryParams: {'page': _currentPage, 'limit': 10},
      );

      if (response.isSuccess && response.body != null) {
        final result = QuestionListResponse.fromJson(response.body!);
        _append(result.data);
        _meta = result.meta;
      } else {
        _currentPage--;
        _errorMessage = response.body?['message'] ?? 'Failed to load more';
      }
    } catch (e) {
      _currentPage--;
      _errorMessage = e.toString();
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }

  void prepend(QuestionModel question) {
    _questionMap[question.id] = question;
    _questionIds.insert(0, question.id);
    update();
  }

  void incrementCommentCount(String questionId) {
    final question = _questionMap[questionId];
    if (question == null) return;
    // answers list length drives comment count in the viewModel,
    // so we don't need a separate counter — just update() to reflect
    // any change that was already made server-side.
    update();
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
    update();
  }

  void appendPollOption(String questionId, PollOptionModel option) {
    final question = _questionMap[questionId];
    if (question == null) return;
    _questionMap[questionId] = question.copyWith(
      options: [...question.options, option],
    );
    update();
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
    final newVoter = VoterModel(userId: userId, name: userName, avatar: userAvatar);

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
    update();
  }

  void _append(List<QuestionModel> items) {
    for (final item in items) {
      _questionMap[item.id] = item;
      if (!_questionIds.contains(item.id)) _questionIds.add(item.id);
    }
  }
}