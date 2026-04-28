import 'package:get/get.dart';
import '../../../core/enums/recent_activity.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/constants/app_url.dart';
import '../../../data/models/common/paginatation_model.dart';
import '../../../data/models/recent_activity/question_activity_model.dart';
import '../../../data/models/recent_activity/answer_activity_model.dart';
import '../../../data/models/recent_activity/review_activity_model.dart';
import '../../../data/models/recent_activity/business_activity_model.dart';
import '../../../data/models/recent_activity/recent_actvity_model.dart';

class RecentActivityController extends GetxController {
  final NetworkCaller _networkCaller = Get.find<NetworkCaller>();

  final Map<RecentActivityType, bool> _loadingMap = {};
  final Map<RecentActivityType, int> _pageMap = {
    RecentActivityType.questions: 1,
    RecentActivityType.answered: 1,
    RecentActivityType.reviews: 1,
    RecentActivityType.business: 1,
  };

  final Map<RecentActivityType, PaginationMeta?> _metaMap = {};

  String? errorMessage;

  List<QuestionActivityModel> questions = [];
  List<AnsweredActivityModel> answered = [];
  List<ReviewActivityModel> reviews = [];
  List<BusinessActivityModel> businesses = [];

  RecentActivityType currentType = RecentActivityType.questions;

  // ─────────────────────────────
  // HELPERS
  // ─────────────────────────────
  bool isLoadingType(RecentActivityType type) =>
      _loadingMap[type] ?? false;

  bool hasNextPage(RecentActivityType type) =>
      _metaMap[type]?.hasNextPage ?? false;

  // ─────────────────────────────
  // CHANGE TAB (NO DUPLICATE CALL)
  // ─────────────────────────────
  void changeType(RecentActivityType type) {
    currentType = type;

    final hasData = switch (type) {
      RecentActivityType.questions => questions.isNotEmpty,
      RecentActivityType.answered => answered.isNotEmpty,
      RecentActivityType.reviews => reviews.isNotEmpty,
      RecentActivityType.business => businesses.isNotEmpty,
    };

    if (hasData) {
      update();
      return;
    }

    _pageMap[type] = 1;
    fetchActivities(type);
  }

  // ─────────────────────────────
  // LOAD MORE
  // ─────────────────────────────
  void loadMore(RecentActivityType type) {
    if (!hasNextPage(type)) return;

    fetchActivities(type, page: _pageMap[type]! + 1);
  }

  // ─────────────────────────────
  // API CALL
  // ─────────────────────────────
  Future<void> fetchActivities(
      RecentActivityType type, {
        int page = 1,
      }) async {
    try {
      _loadingMap[type] = true;
      errorMessage = null;
      update();

      final url =
          "${AppUrl.recentActivity}?type=${type.toJson}&page=$page&limit=10";

      final response = await _networkCaller.getRequest(url: url);

      if (!response.isSuccess) {
        errorMessage =
            response.errorMessage ?? "Something went wrong";
        return;
      }

      final json = response.body!;
      _pageMap[type] = page;

      switch (type) {
        case RecentActivityType.questions:
          final res =
          RecentActivityResponse<QuestionActivityModel>.fromJson(
            json,
            QuestionActivityModel.fromJson,
          );

          questions = page == 1
              ? res.data
              : [...questions, ...res.data];
          _metaMap[type] = res.meta;
          break;

        case RecentActivityType.answered:
          final res =
          RecentActivityResponse<AnsweredActivityModel>.fromJson(
            json,
            AnsweredActivityModel.fromJson,
          );

          answered = page == 1
              ? res.data
              : [...answered, ...res.data];
          _metaMap[type] = res.meta;
          break;

        case RecentActivityType.reviews:
          final res =
          RecentActivityResponse<ReviewActivityModel>.fromJson(
            json,
            ReviewActivityModel.fromJson,
          );

          reviews = page == 1
              ? res.data
              : [...reviews, ...res.data];
          _metaMap[type] = res.meta;
          break;

        case RecentActivityType.business:
          final res =
          RecentActivityResponse<BusinessActivityModel>.fromJson(
            json,
            BusinessActivityModel.fromJson,
          );

          businesses = page == 1
              ? res.data
              : [...businesses, ...res.data];
          _metaMap[type] = res.meta;
          break;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _loadingMap[type] = false;
      update();
    }
  }
}