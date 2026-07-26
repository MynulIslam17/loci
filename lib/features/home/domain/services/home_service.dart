import 'package:loci/features/my_business/data/models/ad_item_model.dart';
import 'package:loci/features/community/data/models/comment_model.dart';
import 'package:loci/features/home/data/models/question_list_response.dart';
import 'package:loci/features/home/data/models/poll_option_model.dart';
import 'package:loci/features/home/data/models/question_model.dart';
import 'package:loci/features/home/data/repositories/home_repository.dart';

/// Domain orchestration for home. Controllers call this — never NetworkCaller.
class HomeService {
  final HomeRepository _repository;

  HomeService(this._repository);

  Future<List<AdItemModel>> getAds() async {
    final body = await _repository.getAds();
    final data = body['data'];
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdItemModel.fromJson)
        .toList();
  }

  Future<QuestionListResponse> getQuestions({
    required int page,
    required int limit,
  }) async {
    final body = await _repository.getQuestions(page: page, limit: limit);
    return QuestionListResponse.fromJson(body);
  }

  Future<QuestionModel?> postQuestion({
    required String content,
    required String category,
    String type = 'question',
  }) async {
    final body = await _repository.postQuestion(
      content: content,
      category: category,
      type: type,
    );
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return QuestionModel.fromJson(data);
    }
    return null;
  }

  /// Adds a poll option and returns the newly created option.
  ///
  /// Returns null when the request succeeded but the response shape could
  /// not be parsed — callers should refresh the list in that case rather
  /// than treat it as a failure.
  Future<PollOptionModel?> addPollOption({
    required String questionId,
    required String text,
    String? imageUrl,
  }) async {
    final body = await _repository.addPollOption(
      questionId: questionId,
      text: text,
      imageUrl: imageUrl,
    );
    final data = body['data'];
    if (data is! Map<String, dynamic>) return null;

    // Shape 1: full updated question — take the newest option.
    final options = data['options'];
    if (options is List && options.isNotEmpty) {
      final last = options.last;
      if (last is Map<String, dynamic>) return PollOptionModel.fromJson(last);
    }

    // Shape 2: just the created option object.
    if (data['text'] != null) return PollOptionModel.fromJson(data);

    return null;
  }

  Future<String> submitVote({
    required String questionId,
    required String optionId,
  }) async {
    final body = await _repository.submitVote(
      questionId: questionId,
      optionId: optionId,
    );
    return body['message']?.toString() ?? 'Vote recorded';
  }

  Future<void> toggleLike({required String questionId}) {
    return _repository.toggleLike(questionId: questionId);
  }

  Future<CommentResponse> getQuestionAnswers({
    required String questionId,
    required int page,
    required int limit,
  }) async {
    final body = await _repository.getQuestionAnswers(
      questionId: questionId,
      page: page,
      limit: limit,
    );
    return CommentResponse.fromJson(body);
  }

  Future<void> postAnswer({
    required String questionId,
    required String content,
  }) async {
    await _repository.postAnswer(questionId: questionId, content: content);
  }
}
