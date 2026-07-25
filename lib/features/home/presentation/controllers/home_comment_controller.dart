import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/community/data/models/comment_model.dart';
import 'package:loci/features/home/domain/services/home_service.dart';
import 'package:loci/features/home/presentation/controllers/question_list_controller.dart';

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
  HomeCommentController(this._service);

  final HomeService _service;

  static const int _pageSize = 20;

  final ScrollController scrollController = ScrollController();

  /// Per-question cache so reopening the same sheet doesn't refetch from
  /// scratch. Lives for the home screen's lifetime (controller is tagged
  /// 'home' and deleted on dispose).
  final Map<String, _AnswerThread> _threads = {};

  final isLoading = false.obs;
  final isPaginating = false.obs;
  final isPosting = false.obs;
  final errorMessage = RxnString();
  final comments = <CommentModel>[].obs;
  final hasNextPage = false.obs;
  String? _currentQuestionId;

  _AnswerThread? get _active =>
      _currentQuestionId == null ? null : _threads[_currentQuestionId];

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

  void _syncActiveThread() {
    final thread = _active;
    comments.assignAll(thread?.comments ?? const []);
    hasNextPage.value = thread?.hasNextPage ?? false;
  }

  // -------------------------------------------------
  // OPEN A QUESTION'S ANSWERS
  //  • cached  → show instantly, then silently refresh page 1
  //  • no cache → full load with a spinner
  // -------------------------------------------------
  Future<void> fetchComments({required String questionId}) async {
    _currentQuestionId = questionId;
    errorMessage.value = null;

    final cached = _threads[questionId];
    if (cached != null && cached.comments.isNotEmpty) {
      // Instant display from cache — no spinner, no blank frame.
      isLoading.value = false;
      _syncActiveThread();

      // Only auto-refresh single-page threads: refreshing a paginated thread
      // would reset it to page 1 and drop the extra pages the user loaded.
      if (cached.currentPage == 1) {
        await _fetchFirstPage(questionId, silent: true);
      }
      return;
    }

    // First time for this question — load with a spinner.
    isLoading.value = true;
    _syncActiveThread();
    await _fetchFirstPage(questionId, silent: false);
  }

  /// Fetches page 1 and stores it in the cache. When [silent] we never toggle
  /// the spinner or surface errors (the user is already looking at cached data).
  Future<void> _fetchFirstPage(
    String questionId, {
    required bool silent,
  }) async {
    try {
      final parsed = await _service.getQuestionAnswers(
        questionId: questionId,
        page: 1,
        limit: _pageSize,
      );

      // The user may have closed/switched sheets while this was in flight.
      if (questionId != _currentQuestionId) return;

      _threads[questionId] = _AnswerThread(
        comments: parsed.comments,
        currentPage: parsed.meta.page,
        hasNextPage: parsed.meta.hasNextPage,
      );
    } catch (e) {
      if (!silent && questionId == _currentQuestionId) {
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      if (questionId == _currentQuestionId) {
        isLoading.value = false;
        _syncActiveThread();
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
    if (isPaginating.value || isLoading.value || !thread.hasNextPage) return;

    try {
      isPaginating.value = true;

      final nextPage = thread.currentPage + 1;
      final parsed = await _service.getQuestionAnswers(
        questionId: questionId,
        page: nextPage,
        limit: _pageSize,
      );

      thread.comments = [...thread.comments, ...parsed.comments];
      thread.currentPage = parsed.meta.page;
      thread.hasNextPage = parsed.meta.hasNextPage;
      _syncActiveThread();
    } catch (_) {
      // A failed page load is non-fatal — keep what's already loaded.
    } finally {
      isPaginating.value = false;
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
      isPosting.value = true;
      errorMessage.value = null;

      await _service.postAnswer(
        questionId: questionId,
        content: content.trim(),
      );

      Get.find<QuestionListController>().incrementCommentCount(questionId);
      // Refresh the cached first page so the new answer appears, without a
      // full-screen loader (the existing list stays visible meanwhile).
      await _fetchFirstPage(questionId, silent: true);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isPosting.value = false;
    }
  }
}
