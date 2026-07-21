import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/comment/comment_model.dart';
import 'package:loci/presentation/controllers/home/question_list_controller.dart';

/// Cached answers + pagination state for a single question.
class _AnswerThread {
  List<CommentModel> comments;
  int currentPage;
  bool hasNextPage;

  _AnswerThread({
    this.comments = const [],
    this.currentPage = 1,
    this.hasNextPage = false,
  });
}

class HomeCommentController extends GetxController {
  static const int _pageSize = 20;

  final ScrollController scrollController = ScrollController();

  /// Per-question cache so reopening the same sheet doesn't refetch from
  /// scratch. Lives for the home screen's lifetime (controller is tagged
  /// 'home' and deleted on dispose).
  final Map<String, _AnswerThread> _threads = {};

  bool _isLoading = false;
  bool _isPaginating = false;
  bool _isPosting = false;
  String? _errorMessage;
  String? _currentQuestionId;

  bool get isLoading => _isLoading;
  bool get isPaginating => _isPaginating;
  bool get isPosting => _isPosting;
  String? get errorMessage => _errorMessage;

  _AnswerThread? get _active =>
      _currentQuestionId == null ? null : _threads[_currentQuestionId];

  List<CommentModel> get comments => _active?.comments ?? const [];
  bool get hasNextPage => _active?.hasNextPage ?? false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      loadMoreComments();
    }
  }

  // -------------------------------------------------
  // OPEN A QUESTION'S ANSWERS
  //  • cached  → show instantly, then silently refresh page 1
  //  • no cache → full load with a spinner
  // -------------------------------------------------
  Future<void> fetchComments({required String questionId}) async {
    _currentQuestionId = questionId;
    _errorMessage = null;

    final cached = _threads[questionId];
    if (cached != null && cached.comments.isNotEmpty) {
      // Instant display from cache — no spinner, no blank frame.
      _isLoading = false;
      update();

      // Only auto-refresh single-page threads: refreshing a paginated thread
      // would reset it to page 1 and drop the extra pages the user loaded.
      if (cached.currentPage == 1) {
        await _fetchFirstPage(questionId, silent: true);
      }
      return;
    }

    // First time for this question — load with a spinner.
    _isLoading = true;
    update();
    await _fetchFirstPage(questionId, silent: false);
  }

  /// Fetches page 1 and stores it in the cache. When [silent] we never toggle
  /// the spinner or surface errors (the user is already looking at cached data).
  Future<void> _fetchFirstPage(
    String questionId, {
    required bool silent,
  }) async {
    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.questionAnswersList(questionId),
        queryParams: {'page': 1, 'limit': _pageSize},
      );

      // The user may have closed/switched sheets while this was in flight.
      if (questionId != _currentQuestionId) return;

      if (response.isSuccess && response.body != null) {
        final parsed = CommentResponse.fromJson(
          response.body as Map<String, dynamic>,
        );
        _threads[questionId] = _AnswerThread(
          comments: parsed.comments,
          currentPage: parsed.meta.page,
          hasNextPage: parsed.meta.hasNextPage,
        );
      } else if (!silent) {
        _errorMessage =
            response.body?['message'] ?? 'Failed to load comments';
      }
    } catch (e) {
      if (!silent && questionId == _currentQuestionId) {
        _errorMessage = e.toString();
      }
    } finally {
      if (questionId == _currentQuestionId) {
        _isLoading = false;
        update();
      }
    }
  }

  // -------------------------------------------------
  // LOAD MORE (next page) — appended to the cached thread
  // -------------------------------------------------
  Future<void> loadMoreComments() async {
    final questionId = _currentQuestionId;
    final thread = _active;
    if (questionId == null || thread == null) return;
    if (_isPaginating || _isLoading || !thread.hasNextPage) return;

    try {
      _isPaginating = true;
      update();

      final nextPage = thread.currentPage + 1;
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.questionAnswersList(questionId),
        queryParams: {'page': nextPage, 'limit': _pageSize},
      );

      if (response.isSuccess && response.body != null) {
        final parsed = CommentResponse.fromJson(
          response.body as Map<String, dynamic>,
        );
        thread.comments = [...thread.comments, ...parsed.comments];
        thread.currentPage = parsed.meta.page;
        thread.hasNextPage = parsed.meta.hasNextPage;
      }
    } catch (_) {
      // A failed page load is non-fatal — keep what's already loaded.
    } finally {
      _isPaginating = false;
      update();
    }
  }

  // -------------------------------------------------
  // POST NEW ANSWER / COMMENT
  // -------------------------------------------------
  Future<void> postComment({
    required String content,
    required String questionId,
  }) async {
    if (content.trim().isEmpty) return;

    try {
      _isPosting = true;
      _errorMessage = null;
      update();

      final response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.questionAnswers(questionId),
        body: {'content': content.trim()},
      );

      if (response.isSuccess) {
        Get.find<QuestionListController>().incrementCommentCount(questionId);
        // Refresh the cached first page so the new answer appears, without a
        // full-screen loader (the existing list stays visible meanwhile).
        await _fetchFirstPage(questionId, silent: true);
      } else {
        _errorMessage =
            response.body?['message'] ?? 'Failed to post comment';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isPosting = false;
      update();
    }
  }
}
