import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/enums/rsvp_status.dart';
import 'package:loci/features/event/data/models/event_list_model.dart';
import 'package:loci/features/event/domain/services/event_service.dart';

class EventListController extends GetxController {
  EventListController(this._service);

  final EventService _service;

  final RxBool _isLoading = false.obs;
  final RxBool _isPaginationLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final RxList<EventModel> _eventList = <EventModel>[].obs;

  /// Current page number for pagination
  int _currentPage = 1;

  /// Flag to check if there is a next page
  bool _hasNextPage = true;

  // use to change the limit of events per page
  final int _limit = 20;

  String _searchQuery = '';
  Timer? _searchDebounce;

  /// Public getters
  bool get isLoading => _isLoading.value;
  bool get isPaginationLoading => _isPaginationLoading.value;
  String? get errorMessage => _errorMessage.value;
  List<EventModel> get eventList => _eventList;
  bool get hasMore => _hasNextPage;
  String get searchQuery => _searchQuery;

  /// Debounced search — updates the query and refetches from the API.
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

  /// Fetch events from API
  /// [isRefresh] → if true, reset page & clear list
  Future<void> fetchEvents({bool isRefresh = false, String? businessId}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _eventList.clear();
    }

    _isLoading.value = true;
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
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load next page for pagination
  Future<void> loadMoreEvents({String? businessId}) async {
    if (!_hasNextPage || _isPaginationLoading.value) return;

    _isPaginationLoading.value = true;
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
      _isPaginationLoading.value = false;
    }
  }

  /// update rsvp status and count locally
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

  /// reset the controller
  void reset() {
    _isLoading.value = false;
    _isPaginationLoading.value = false;
    _errorMessage.value = null;
    _eventList.clear();
    _currentPage = 1;
    _hasNextPage = true;
    _searchQuery = '';
    _searchDebounce?.cancel();
  }
}
