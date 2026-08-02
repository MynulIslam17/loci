import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/features/event/data/models/event_list_model.dart';
import 'package:loci/features/event/domain/services/event_service.dart';

class EventListController extends GetxController {
  EventListController(this._service);

  final EventService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final Rxn<String> _errorMessage = Rxn<String>();
  final RxList<EventModel> _eventList = <EventModel>[].obs;

  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 20;

  String _searchQuery = '';
  Timer? _searchDebounce;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isLoading => isInitialLoading;
  bool get isPaginationLoading => _fetch.loadingMore.value;
  String? get errorMessage => _errorMessage.value;
  List<EventModel> get eventList => _eventList;
  bool get hasMore => _hasNextPage;
  String get searchQuery => _searchQuery;

  void onSearchChanged(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchEvents(isRefresh: true);
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> fetchEvents({bool isRefresh = false, String? businessId}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
    }

    _fetch.beginFirstPage(isRefresh: isRefresh);
    _errorMessage.value = null;

    try {
      final model = await _service.getEvents(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
        search: _searchQuery,
      );
      _eventList.assignAll(model.events);
      _hasNextPage = model.meta.hasNextPage;
      _fetch.endFirstPage();
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }

  Future<void> loadMoreEvents({String? businessId}) async {
    if (!_hasNextPage ||
        isPaginationLoading ||
        isInitialLoading ||
        isRefreshing) {
      return;
    }

    _fetch.beginLoadMore();
    _currentPage++;

    try {
      final model = await _service.getEvents(
        page: _currentPage,
        limit: _limit,
        businessId: businessId,
        search: _searchQuery,
      );
      _eventList.addAll(model.events);
      _hasNextPage = model.meta.hasNextPage;
    } catch (e) {
      _currentPage--;
      _errorMessage.value = 'Pagination error: $e';
    } finally {
      _fetch.endLoadMore();
    }
  }

  void updateRsvpStatus(String eventId, RsvpStatus status) {
    final index = _eventList.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _eventList[index] = _eventList[index].copyWith(
        myRsvpStatus: status,
        goingCount: status == RsvpStatus.going
            ? _eventList[index].goingCount + 1
            : _eventList[index].goingCount,
      );
    }
  }

  void reset() {
    _fetch.reset();
    _errorMessage.value = null;
    _eventList.clear();
    _currentPage = 1;
    _hasNextPage = true;
    _searchQuery = '';
    _searchDebounce?.cancel();
  }
}
