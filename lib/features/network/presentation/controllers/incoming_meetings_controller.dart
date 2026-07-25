import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/network/data/models/meeting/meeting_models.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

class IncomingMeetingsController extends GetxController {
  IncomingMeetingsController(this._service);

  final NetworkService _service;

  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();

  /// Server-filtered list for the currently selected day.
  final RxList<IncomingMeetingModel> _meetings = <IncomingMeetingModel>[].obs;
  final Rxn<PaginationMeta> _meta = Rxn<PaginationMeta>();

  /// Dates that have at least one incoming meeting — drives calendar dots.
  /// Built up from every filtered fetch.
  final RxSet<DateTime> _markedDates = <DateTime>{}.obs;

  /// Active date filter (`date=YYYY-MM-DD`). Defaults to today.
  final Rxn<DateTime> _selectedDate = Rxn<DateTime>();

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String? get errorMessage => _errorMessage.value;
  List<IncomingMeetingModel> get meetings => _meetings;
  PaginationMeta? get meta => _meta.value;
  Set<DateTime> get markedDates => _markedDates;
  DateTime? get selectedDate => _selectedDate.value;

  int _currentPage = 1;
  static const int _limit = 10;
  static const int _markersLimit = 100;

  final ScrollController scrollController = ScrollController();

  bool get hasNextPage => meta?.hasNextPage ?? false;

  @override
  void onInit() {
    super.onInit();
    _selectedDate.value = _normalize(DateTime.now());
    fetchMarkerDates();
    fetchIncomingMeetings();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasNextPage) {
      loadMore();
    }
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> setSelectedDate(DateTime date) async {
    final normalized = _normalize(date);
    if (selectedDate == normalized) return;
    _selectedDate.value = normalized;
    await fetchIncomingMeetings();
  }

  Future<void> fetchIncomingMeetings() async {
    _isLoading.value = true;
    _errorMessage.value = null;
    _currentPage = 1;
    _meetings.clear();

    await _loadPage(_currentPage);

    _isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasNextPage) return;

    _isLoadingMore.value = true;
    _currentPage++;

    await _loadPage(_currentPage);

    _isLoadingMore.value = false;
  }

  void _addMarker(String raw) {
    final parsed = DateParserHelper.parseDate(raw);
    if (parsed == null) return;
    _markedDates.add(_normalize(parsed));
  }

  /// One unfiltered call dedicated to the calendar dots. Best-effort.
  Future<void> fetchMarkerDates() async {
    try {
      final result = await _service.getIncomingMeetings(
        page: 1,
        limit: _markersLimit,
      );
      for (final m in result.data) {
        _addMarker(m.meetingDate);
      }
    } catch (_) {
      // best-effort
    }
  }

  /// Replace a single meeting in the displayed list (used by the respond
  /// controller after confirm/reject).
  void replaceMeeting(IncomingMeetingModel updated) {
    final index = meetings.indexWhere((m) => m.id == updated.id);
    if (index == -1) return;
    _meetings[index] = updated;
  }

  Future<void> _loadPage(int page) async {
    try {
      final result = await _service.getIncomingMeetings(
        page: page,
        limit: _limit,
        date: selectedDate != null
            ? DateParserHelper.toApiDate(selectedDate)
            : null,
      );
      _meetings.addAll(result.data);
      _meta.value = result.meta;
      for (final m in result.data) {
        _addMarker(m.meetingDate);
      }
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (page > 1) _currentPage--;
    }
  }
}
