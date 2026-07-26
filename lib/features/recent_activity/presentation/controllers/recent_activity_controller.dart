import 'package:get/get.dart';
import 'package:loci/core/enums/recent_activity.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/recent_activity/data/models/answer_activity_model.dart';
import 'package:loci/features/recent_activity/data/models/business_activity_model.dart';
import 'package:loci/features/recent_activity/data/models/question_activity_model.dart';
import 'package:loci/features/recent_activity/data/models/review_activity_model.dart';
import 'package:loci/features/recent_activity/domain/services/recent_activity_service.dart';

class RecentActivityController extends GetxController {
  RecentActivityController(this._service);

  final RecentActivityService _service;

  final RxMap<RecentActivityType, bool> _loadingMap =
      <RecentActivityType, bool>{}.obs;
  final Map<RecentActivityType, int> _pageMap = {
    RecentActivityType.questions: 1,
    RecentActivityType.answered: 1,
    RecentActivityType.reviews: 1,
    RecentActivityType.business: 1,
  };

  final RxMap<RecentActivityType, PaginationMeta?> _metaMap =
      <RecentActivityType, PaginationMeta?>{}.obs;

  final Rxn<String> _errorMessage = Rxn<String>();
  String? get errorMessage => _errorMessage.value;

  final RxList<QuestionActivityModel> _questions =
      <QuestionActivityModel>[].obs;
  final RxList<AnsweredActivityModel> _answered = <AnsweredActivityModel>[].obs;
  final RxList<ReviewActivityModel> _reviews = <ReviewActivityModel>[].obs;
  final RxList<BusinessActivityModel> _businesses =
      <BusinessActivityModel>[].obs;

  List<QuestionActivityModel> get questions => _questions;
  List<AnsweredActivityModel> get answered => _answered;
  List<ReviewActivityModel> get reviews => _reviews;
  List<BusinessActivityModel> get businesses => _businesses;

  RecentActivityType currentType = RecentActivityType.questions;

  bool isLoadingType(RecentActivityType type) => _loadingMap[type] ?? false;

  bool hasNextPage(RecentActivityType type) =>
      _metaMap[type]?.hasNextPage ?? false;

  void changeType(RecentActivityType type) {
    currentType = type;

    final hasData = switch (type) {
      RecentActivityType.questions => _questions.isNotEmpty,
      RecentActivityType.answered => _answered.isNotEmpty,
      RecentActivityType.reviews => _reviews.isNotEmpty,
      RecentActivityType.business => _businesses.isNotEmpty,
    };

    if (hasData) {
      return;
    }

    _pageMap[type] = 1;
    fetchActivities(type);
  }

  void loadMore(RecentActivityType type) {
    if (!hasNextPage(type)) return;
    fetchActivities(type, page: _pageMap[type]! + 1);
  }

  Future<void> fetchActivities(RecentActivityType type, {int page = 1}) async {
    try {
      _loadingMap[type] = true;
      _errorMessage.value = null;

      switch (type) {
        case RecentActivityType.questions:
          final res = await _service.getQuestions(page: page);
          _questions.assignAll(
            page == 1 ? res.data : [..._questions, ...res.data],
          );
          _metaMap[type] = res.meta;
          break;
        case RecentActivityType.answered:
          final res = await _service.getAnswered(page: page);
          _answered.assignAll(
            page == 1 ? res.data : [..._answered, ...res.data],
          );
          _metaMap[type] = res.meta;
          break;
        case RecentActivityType.reviews:
          final res = await _service.getReviews(page: page);
          _reviews.assignAll(page == 1 ? res.data : [..._reviews, ...res.data]);
          _metaMap[type] = res.meta;
          break;
        case RecentActivityType.business:
          final res = await _service.getBusinesses(page: page);
          _businesses.assignAll(
            page == 1 ? res.data : [..._businesses, ...res.data],
          );
          _metaMap[type] = res.meta;
          break;
      }

      _pageMap[type] = page;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loadingMap[type] = false;
    }
  }
}
