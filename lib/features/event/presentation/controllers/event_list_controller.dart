import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/core/services/connectivity/connectivity_service.dart';
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
  final List<EventModel> _unfilteredEvents = <EventModel>[];
  bool _unfilteredHasNextPage = true;

  int _currentPage = 1;
  bool _hasNextPage = true;
  final int _limit = 20;

  String _searchQuery = '';
  Timer? _searchDebounce;
  int _searchSeq = 0;
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
        final parsed = cached
            .map((e) => EventModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _eventList.assignAll(parsed);
        _unfilteredEvents.assignAll(parsed);
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
    final hadSearch = _searchQuery.trim().isNotEmpty;
    _searchQuery = query;
    final seq = ++_searchSeq;
    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      if (hadSearch) {
        _restoreUnfilteredList(sequenceToken: seq);
      }
    } else {
      isSearching.value = true;
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        fetchEvents(isSearch: true, sequenceToken: seq);
      });
    }
  }

  void submitSearch(String query) {
    _searchDebounce?.cancel();
    if (query.trim() == _searchQuery && query.trim().isNotEmpty) return;
    _searchQuery = query;
    final seq = ++_searchSeq;
    if (query.trim().isEmpty) {
      _restoreUnfilteredList(sequenceToken: seq);
    } else {
      isSearching.value = true;
      fetchEvents(isSearch: true, sequenceToken: seq);
    }
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return; // Do not refetch if already empty
    _searchQuery = '';
    _searchDebounce?.cancel();
    final seq = ++_searchSeq;
    _restoreUnfilteredList(sequenceToken: seq);
  }

  void _restoreUnfilteredList({int? sequenceToken}) {
    if (_unfilteredEvents.isNotEmpty) {
      _eventList.assignAll(_unfilteredEvents);
      _hasNextPage = _unfilteredHasNextPage;
      isSearching.value = false;
      _errorMessage.value = null;
    } else {
      fetchEvents(isSearch: true, sequenceToken: sequenceToken);
    }
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
    int? sequenceToken,
  }) async {
    final currentSeq = sequenceToken ?? ++_searchSeq;

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

      // Discard stale out-of-order response if another search was fired in the meantime
      if (currentSeq != _searchSeq) return;

      _eventList.assignAll(model.events);
      _hasNextPage = model.meta.hasNextPage;
      _fetch.endFirstPage();

      if (_searchQuery.isEmpty && !isSearch) {
        _unfilteredEvents.assignAll(model.events);
        _unfilteredHasNextPage = model.meta.hasNextPage;
      }

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
      if (currentSeq != _searchSeq) return;
      if (_eventList.isEmpty) {
        _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
      _fetch.endFirstPage(markFetched: hasFetched || _eventList.isNotEmpty);
    } finally {
      if (currentSeq == _searchSeq && isSearch) {
        isSearching.value = false;
      }
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
