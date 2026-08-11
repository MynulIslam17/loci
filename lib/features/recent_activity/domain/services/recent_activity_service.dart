import 'package:loci/core/enums/recent_activity.dart';
import 'package:loci/features/recent_activity/data/models/answer_activity_model.dart';
import 'package:loci/features/recent_activity/data/models/business_activity_model.dart';
import 'package:loci/features/recent_activity/data/models/question_activity_model.dart';
import 'package:loci/features/recent_activity/data/models/recent_activity_model.dart';
import 'package:loci/features/recent_activity/data/models/review_activity_model.dart';
import 'package:loci/features/recent_activity/data/repositories/recent_activity_repository.dart';

/// Domain orchestration for recent activity. Controllers call this — never NetworkCaller.
class RecentActivityService {
  final RecentActivityRepository _repository;

  RecentActivityService(this._repository);

  Future<RecentActivityResponse<QuestionActivityModel>> getQuestions({
    required int page,
  }) async {
    final body = await _repository.getActivities(
      type: RecentActivityType.questions,
      page: page,
    );
    return RecentActivityResponse.fromJson(
      body,
      QuestionActivityModel.fromJson,
    );
  }

  Future<RecentActivityResponse<AnsweredActivityModel>> getAnswered({
    required int page,
  }) async {
    final body = await _repository.getActivities(
      type: RecentActivityType.answered,
      page: page,
    );
    return RecentActivityResponse.fromJson(
      body,
      AnsweredActivityModel.fromJson,
    );
  }

  Future<RecentActivityResponse<ReviewActivityModel>> getReviews({
    required int page,
  }) async {
    final body = await _repository.getActivities(
      type: RecentActivityType.reviews,
      page: page,
    );
    return RecentActivityResponse.fromJson(body, ReviewActivityModel.fromJson);
  }

  Future<RecentActivityResponse<BusinessActivityModel>> getBusinesses({
    required int page,
  }) async {
    final body = await _repository.getActivities(
      type: RecentActivityType.business,
      page: page,
    );
    return RecentActivityResponse.fromJson(
      body,
      BusinessActivityModel.fromJson,
    );
  }
}
