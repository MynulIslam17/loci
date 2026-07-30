import 'package:get/get.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/network/data/models/meeting_models.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

class SentMeetingsController extends GetxController {
  SentMeetingsController(this._service);

  final NetworkService _service;

  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();

  /// Server-filtered list for the currently selected day.
  final RxList<SentMeetingModel> _meetings = <SentMeetingModel>[].obs;
  final Rxn<PaginationMeta> _meta = Rxn<PaginationMeta>();

  /// Dates that have at least one meeting — drives calendar dots. Built up
  /// from every filtered fetch (today on cold load, plus any day the user
  /// taps on the calendar afterwards).
  final RxSet<DateTime> _markedDates = <DateTime>{}.obs;

  /// Active date filter (`date=YYYY-MM-DD`). Defaults to today.
  final Rxn<DateTime> _selectedDate = Rxn<DateTime>();

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String? get errorMessage => _errorMessage.value;
  List<SentMeetingModel> get meetings => _meetings;
  PaginationMeta? get meta => _meta.value;
  Set<DateTime> get markedDates => _markedDates;
  DateTime? get selectedDate => _selectedDate.value;

  int _currentPage = 1;
  static const int _limit = 10;
  static const int _markersLimit = 100;

  bool get hasNextPage => meta?.hasNextPage ?? false;

  @override
  void onInit() {
    super.onInit();
    _selectedDate.value = _normalize(DateTime.now());
    fetchMarkerDates();
    fetchSentMeetings();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Switching the active day fires a new server-filtered fetch.
  Future<void> setSelectedDate(DateTime date) async {
    final normalized = _normalize(date);
    if (selectedDate == normalized) return;
    _selectedDate.value = normalized;
    await fetchSentMeetings();
  }

  Future<void> fetchSentMeetings() async {
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

  /// One unfiltered call dedicated to the calendar dots — without it, the
  /// client has no way to know which dates have meetings beyond whichever day
  /// the user has filtered to. Best-effort; failures don't surface to the UI.
  Future<void> fetchMarkerDates() async {
    try {
      final result = await _service.getSentMeetings(
        page: 1,
        limit: _markersLimit,
      );
      for (final m in result.data) {
        _addMarker(m.meetingDate);
      }
    } catch (_) {
      // dots are best-effort
    }
  }

  Future<void> _loadPage(int page) async {
    try {
      final result = await _service.getSentMeetings(
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
