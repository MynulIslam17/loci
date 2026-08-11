import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';

/// Home data layer: remote HTTP via [NetworkCaller].
class HomeRepository {
  final NetworkCaller _network;

  HomeRepository(this._network);

  Future<Map<String, dynamic>> getAds() async {
    final res = await _network.getRequest(url: AppUrl.adsList);
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to load ads');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> getQuestions({
    required int page,
    required int limit,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.questionList,
      queryParams: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load questions',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> postQuestion({
    required String content,
    required String category,
    required String type,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.postQuestionHome,
      body: {'content': content, 'type': type, 'category': category},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to post question');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> addPollOption({
    required String questionId,
    required String text,
    String? imageUrl,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.addHomePollQuestionAdd(questionId),
      body: {
        'text': text,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image': imageUrl,
      },
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(res.errorMessage ?? 'Failed to add poll option');
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> submitVote({
    required String questionId,
    required String optionId,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.homeVoteOnPollOption(questionId),
      body: {'optionId': optionId},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to submit vote',
      );
    }
    return res.body!;
  }

  Future<void> toggleLike({required String questionId}) async {
    final res = await _network.postRequest(
      url: AppUrl.homeFeedPostLike(questionId),
      body: {},
    );
    if (!res.isSuccess) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Something went wrong',
      );
    }
  }

  Future<Map<String, dynamic>> getQuestionAnswers({
    required String questionId,
    required int page,
    required int limit,
  }) async {
    final res = await _network.getRequest(
      url: AppUrl.questionAnswersList(questionId),
      queryParams: {'page': page, 'limit': limit},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to load comments',
      );
    }
    return res.body!;
  }

  Future<Map<String, dynamic>> postAnswer({
    required String questionId,
    required String content,
  }) async {
    final res = await _network.postRequest(
      url: AppUrl.questionAnswers(questionId),
      body: {'content': content},
    );
    if (!res.isSuccess || res.body == null) {
      throw Exception(
        res.body?['message'] ?? res.errorMessage ?? 'Failed to post comment',
      );
    }
    return res.body!;
  }
}
