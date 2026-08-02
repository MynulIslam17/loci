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

  final RxMap<RecentActivityType, bool> _initialLoadingMap =
      <RecentActivityType, bool>{}.obs;
  final RxMap<RecentActivityType, bool> _refreshingMap =
      <RecentActivityType, bool>{}.obs;
  final RxMap<RecentActivityType, bool> _loadingMoreMap =
      <RecentActivityType, bool>{}.obs;
  final RxMap<RecentActivityType, bool> _hasFetchedMap =
      <RecentActivityType, bool>{}.obs;
  final RxMap<RecentActivityType, String?> _errorMap =
      <RecentActivityType, String?>{}.obs;

  final Map<RecentActivityType, int> _pageMap = {
    RecentActivityType.questions: 1,
    RecentActivityType.answered: 1,
    RecentActivityType.reviews: 1,
    RecentActivityType.business: 1,
  };

  final RxMap<RecentActivityType, PaginationMeta?> _metaMap =
      <RecentActivityType, PaginationMeta?>{}.obs;

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

  bool isInitialLoading(RecentActivityType type) =>
      _initialLoadingMap[type] ?? false;

  bool isRefreshing(RecentActivityType type) => _refreshingMap[type] ?? false;

  bool isLoadingMore(RecentActivityType type) => _loadingMoreMap[type] ?? false;

  bool hasFetched(RecentActivityType type) => _hasFetchedMap[type] ?? false;

  String? errorFor(RecentActivityType type) => _errorMap[type];

  bool hasNextPage(RecentActivityType type) =>
      _metaMap[type]?.hasNextPage ?? false;

  int itemCount(RecentActivityType type) => switch (type) {
        RecentActivityType.questions => _questions.length,
        RecentActivityType.answered => _answered.length,
        RecentActivityType.reviews => _reviews.length,
        RecentActivityType.business => _businesses.length,
      };

  /// Loads the tab only once; revisiting a tab reuses cached data.
  void ensureLoaded(RecentActivityType type) {
    if (hasFetched(type) || isInitialLoading(type)) return;
    fetchActivities(type);
  }

  Future<void> reload(RecentActivityType type) =>
      fetchActivities(type, page: 1, force: true);

  Future<void> loadMore(RecentActivityType type) async {
    if (!hasNextPage(type) ||
        isInitialLoading(type) ||
        isRefreshing(type) ||
        isLoadingMore(type)) {
      return;
    }
    await fetchActivities(type, page: _pageMap[type]! + 1);
  }

  void removeBusiness(String businessId) {
    _businesses.removeWhere((item) => item.id == businessId);
    final meta = _metaMap[RecentActivityType.business];
    if (meta != null && meta.total > 0) {
      _metaMap[RecentActivityType.business] = PaginationMeta(
        total: meta.total - 1,
        page: meta.page,
        limit: meta.limit,
        totalPages: meta.totalPages,
        hasNextPage: meta.hasNextPage,
        hasPrevPage: meta.hasPrevPage,
      );
    }
  }

  Future<void> fetchActivities(
    RecentActivityType type, {
    int page = 1,
    bool force = false,
  }) async {
    if (page == 1 && !force && hasFetched(type)) return;

    final isFirstPage = page == 1;
    if (isFirstPage) {
      if (force && hasFetched(type)) {
        _refreshingMap[type] = true;
      } else {
        _initialLoadingMap[type] = true;
      }
    } else {
      _loadingMoreMap[type] = true;
    }
    _errorMap[type] = null;

    try {
      switch (type) {
        case RecentActivityType.questions:
          final res = await _service.getQuestions(page: page);
          if (isFirstPage) {
            _questions.assignAll(res.data);
          } else {
            _questions.addAll(res.data);
          }
          _metaMap[type] = res.meta;
          break;
        case RecentActivityType.answered:
          final res = await _service.getAnswered(page: page);
          if (isFirstPage) {
            _answered.assignAll(res.data);
          } else {
            _answered.addAll(res.data);
          }
          _metaMap[type] = res.meta;
          break;
        case RecentActivityType.reviews:
          final res = await _service.getReviews(page: page);
          if (isFirstPage) {
            _reviews.assignAll(res.data);
          } else {
            _reviews.addAll(res.data);
          }
          _metaMap[type] = res.meta;
          break;
        case RecentActivityType.business:
          final res = await _service.getBusinesses(page: page);
          if (isFirstPage) {
            _businesses.assignAll(res.data);
          } else {
            _businesses.addAll(res.data);
          }
          _metaMap[type] = res.meta;
          break;
      }

      _pageMap[type] = page;
      _hasFetchedMap[type] = true;
    } catch (e) {
      _errorMap[type] = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (isFirstPage) {
        _initialLoadingMap[type] = false;
        _refreshingMap[type] = false;
      } else {
        _loadingMoreMap[type] = false;
      }
    }
  }
}
