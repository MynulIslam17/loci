import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/comment/comment_model.dart';
import 'package:loci/data/models/home/question_model.dart';
import 'package:loci/presentation/controllers/home/question_list_controller.dart';

class HomeCommentController extends GetxController {
  final ScrollController scrollController = ScrollController();

  bool _isLoading = false;
  bool _isPosting = false;
  String? _errorMessage;
  String? _currentQuestionId;

  List<CommentModel> _comments = [];

  bool get isLoading => _isLoading;
  bool get isPosting => _isPosting;
  String? get errorMessage => _errorMessage;
  List<CommentModel> get comments => _comments;

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // -------------------------------------------------
  // FETCH COMMENTS (embedded in question details)
  // -------------------------------------------------
  Future<void> fetchComments({required String questionId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _currentQuestionId = questionId;
      _comments = [];
      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.questionDetails(questionId),
      );

      if (response.isSuccess && response.body != null) {
        final question = QuestionModel.fromJson(
          response.body!['data'] as Map<String, dynamic>,
        );
        // Map AnswerModel → CommentModel so PostCommentSection is reusable
        _comments = question.answers
            .map(
              (a) => CommentModel(
                id: a.id,
                content: a.content,
                createdAt: a.createdAt,
                author: CommentAuthor(
                  id: a.user.id,
                  name: a.user.name,
                  avatar: a.user.avatar,
                ),
              ),
            )
            .toList();
      } else {
        _errorMessage =
            response.body?['message'] ?? 'Failed to load comments';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
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

      if (response.isSuccess && response.body != null) {
        // Try to parse the new comment from response, otherwise re-fetch
        try {
          final data = response.body!['data'];
          if (data != null) {
            final newComment = _parseAnswerFromJson(data);
            _comments.insert(0, newComment);
          }
        } catch (_) {
          // If parsing fails, just re-fetch to stay in sync
          await fetchComments(questionId: questionId);
          return;
        }
        // Bump the comment count on the post card
        Get.find<QuestionListController>().incrementCommentCount(questionId);
        update();
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

  // -------------------------------------------------
  // HELPERS
  // -------------------------------------------------
  CommentModel _parseAnswerFromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return CommentModel(
      id: json['_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      author: CommentAuthor(
        id: user['_id'] as String? ?? '',
        name: user['name'] as String? ?? '',
        avatar: user['avatar'] as String? ?? '',
      ),
    );
  }
}
