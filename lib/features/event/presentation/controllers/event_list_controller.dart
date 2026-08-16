import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/core/services/connectivity_service.dart';
import 'package:loci/core/storage/hive_storage_service.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/features/event/data/models/event_list_model.dart';
import 'package:loci/features/event/domain/services/event_service.dart';

class EventListController extends GetxController {
  EventListController(this._service, [HiveStorageService? storage])
      : _storage = storage ??
            (Get.isRegistered<HiveStorageService>()
                ? Get.find<HiveStorageService>()
                : null);

  final EventService _service;
  final HiveStorageService? _storage;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();
  StreamSubscription<void>? _reconnectSub;

  final Rxn<String> _errorMessage = Rxn<String>();
  final RxList<EventModel> _eventList = <EventModel>[].obs;

  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 20;

  String _searchQuery = '';
  Timer? _searchDebounce;
  final RxBool isSearching = false.obs;

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

  @override
  void onInit() {
    super.onInit();

    // Frame-0 instant load from Hive cache
    if (_storage != null && _searchQuery.isEmpty) {
      final cached = _storage.getFeedList('event_list_feed');
      if (cached.isNotEmpty) {
        _eventList.assignAll(
          cached
              .map((e) => EventModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
        _fetch.endFirstPage(markFetched: true);
      }
    }

    if (Get.isRegistered<ConnectivityService>()) {
      _reconnectSub = Get.find<ConnectivityService>().onReconnect.listen((_) {
        fetchEvents(isRefresh: true);
      });
    }
  }

  void onSearchChanged(String query) {
    if (query == _searchQuery) return;
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchEvents(isSearch: true);
    });
  }

  void clearSearch() {
    _searchQuery = '';
    _searchDebounce?.cancel();
    fetchEvents(isSearch: true);
  }

  @override
  void onClose() {
    _reconnectSub?.cancel();
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> fetchEvents({
    bool isRefresh = false,
    bool isSearch = false,
    String? businessId,
  }) async {
    if (isRefresh || isSearch) {
      _currentPage = 1;
      _hasNextPage = true;
    }

    // Fast Offline Guard: short-circuit immediately if offline
    if (ConnectivityService.isCurrentOffline && !isSearch) {
      _fetch.endFirstPage(markFetched: true);
      return;
    }

    if (isSearch) {
      isSearching.value = true;
    } else {
      _fetch.beginFirstPage(isRefresh: isRefresh);
    }
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

      if (_currentPage == 1 &&
          _searchQuery.isEmpty &&
          _storage != null &&
          model.events.isNotEmpty) {
        _storage.saveFeedList(
          'event_list_feed',
          model.events.map((e) => e.toJson()).toList(),
        );
      }
    } catch (e) {
      if (_eventList.isEmpty) {
        _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
      _fetch.endFirstPage(markFetched: hasFetched || _eventList.isNotEmpty);
    } finally {
      if (isSearch) isSearching.value = false;
    }
  }

  Future<void> loadMoreEvents({String? businessId}) async {
    if (!_hasNextPage ||
        isPaginationLoading ||
        isInitialLoading ||
        isRefreshing) {
      return;
    }

    // Fast Offline Guard: do not paginate when offline
    if (ConnectivityService.isCurrentOffline) return;

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
