import 'package:get/get.dart';

import '../../../core/enums/recent_activity.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/constants/app_url.dart';

import '../../../data/models/common/paginatation_model.dart';
import '../../../data/models/recent_activity/question_activity_model.dart';
import '../../../data/models/recent_activity/answer_activity_model.dart';
import '../../../data/models/recent_activity/recent_actvity_model.dart';
import '../../../data/models/recent_activity/review_activity_model.dart';
import '../../../data/models/recent_activity/business_activity_model.dart';


class RecentActivityController extends GetxController {
  final NetworkCaller _networkCaller = Get.find<NetworkCaller>();

  bool isLoading = false;
  String? errorMessage;

  RecentActivityType currentType = RecentActivityType.questions;

  PaginationMeta? meta;

  // ─────────────────────────────
  // SEPARATE TYPE SAFE LISTS
  // ─────────────────────────────
  List<QuestionActivityModel> questions = [];
  List<AnsweredActivityModel> answered = [];
  List<ReviewActivityModel> reviews = [];
  List<BusinessActivityModel> businesses = [];

  @override
  void onInit() {
    super.onInit();
    fetchActivities(RecentActivityType.questions);
  }

  // ─────────────────────────────
  // FETCH API
  // ─────────────────────────────
  Future<void> fetchActivities(RecentActivityType type) async {
    try {
      isLoading = true;
      errorMessage = null;
      currentType = type;
      update();

      final url =
          "${AppUrl.recentActivity}?type=${type.toJson}";

      final response = await _networkCaller.getRequest(url: url);

      if (!response.isSuccess) {
        errorMessage = response.errorMessage ?? "Something went wrong";
        return;
      }

      final json = response.body!;

      switch (type) {
        case RecentActivityType.questions:
          final res = RecentActivityResponse<QuestionActivityModel>.fromJson(
            json,
                (e) => QuestionActivityModel.fromJson(e),
          );
          questions = res.data;
          meta = res.meta;
          break;

        case RecentActivityType.answered:
          final res = RecentActivityResponse<AnsweredActivityModel>.fromJson(
            json,
                (e) => AnsweredActivityModel.fromJson(e),
          );
          answered = res.data;
          meta = res.meta;
          break;

        case RecentActivityType.reviews:
          final res = RecentActivityResponse<ReviewActivityModel>.fromJson(
            json,
                (e) => ReviewActivityModel.fromJson(e),
          );
          reviews = res.data;
          meta = res.meta;
          break;

        case RecentActivityType.businesses:
          final res = RecentActivityResponse<BusinessActivityModel>.fromJson(
            json,
                (e) => BusinessActivityModel.fromJson(e),
          );
          businesses = res.data;
          meta = res.meta;
          break;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      update();
    }
  }

  void changeType(RecentActivityType type) {
    fetchActivities(type);
  }
}