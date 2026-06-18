import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/data/models/common/paginatation_model.dart';
import 'package:loci/data/models/meeting/meeting_models.dart';

class SentMeetingsController extends GetxController {
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;

  /// Server-filtered list for the currently selected day.
  List<SentMeetingModel> meetings = [];
  PaginationMeta? meta;

  /// Dates that have at least one meeting — drives calendar dots. Built up
  /// from every filtered fetch (today on cold load, plus any day the user
  /// taps on the calendar afterwards).
  Set<DateTime> markedDates = {};

  /// Active date filter (`date=YYYY-MM-DD`). Defaults to today.
  DateTime? selectedDate;

  int _currentPage = 1;
  static const int _limit = 10;
  static const int _markersLimit = 100;

  final ScrollController scrollController = ScrollController();

  bool get hasNextPage => meta?.hasNextPage ?? false;

  @override
  void onInit() {
    super.onInit();
    selectedDate = _normalize(DateTime.now());
    fetchMarkerDates();
    fetchSentMeetings();
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

  /// Switching the active day fires a new server-filtered fetch.
  Future<void> setSelectedDate(DateTime date) async {
    final normalized = _normalize(date);
    if (selectedDate == normalized) return;
    selectedDate = normalized;
    await fetchSentMeetings();
  }

  Future<void> fetchSentMeetings() async {
    isLoading = true;
    errorMessage = null;
    _currentPage = 1;
    meetings = [];
    update();

    await _loadPage(_currentPage);

    isLoading = false;
    update();
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasNextPage) return;

    isLoadingMore = true;
    _currentPage++;
    update();

    await _loadPage(_currentPage);

    isLoadingMore = false;
    update();
  }

  void _addMarker(String raw) {
    final parsed = DateParserHelper.parseDate(raw);
    if (parsed == null) return;
    markedDates.add(_normalize(parsed));
  }

  /// One unfiltered call dedicated to the calendar dots — without it, the
  /// client has no way to know which dates have meetings beyond whichever day
  /// the user has filtered to. Best-effort; failures don't surface to the UI.
  Future<void> fetchMarkerDates() async {
    try {
      final NetworkResponse response =
          await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.sentMeetings,
        queryParams: {'page': 1, 'limit': _markersLimit},
      );

      if (response.isSuccess && response.body != null) {
        final result = SentMeetingsResponse.fromJson(response.body!);
        for (final m in result.data) {
          _addMarker(m.meetingDate);
        }
        update();
      }
    } catch (_) {
      // dots are best-effort
    }
  }

  Future<void> _loadPage(int page) async {
    try {
      final qp = <String, dynamic>{'page': page, 'limit': _limit};
      if (selectedDate != null) {
        qp['date'] = DateParserHelper.toApiDate(selectedDate);
      }

      final NetworkResponse response =
          await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.sentMeetings,
        queryParams: qp,
      );

      if (response.isSuccess && response.body != null) {
        final result = SentMeetingsResponse.fromJson(response.body!);
        meetings = [...meetings, ...result.data];
        meta = result.meta;
        for (final m in result.data) {
          _addMarker(m.meetingDate);
        }
      } else {
        errorMessage = response.body?['message'] ?? 'Failed to load meetings';
        if (page > 1) _currentPage--;
      }
    } catch (e) {
      errorMessage = e.toString();
      if (page > 1) _currentPage--;
    }
  }
}
