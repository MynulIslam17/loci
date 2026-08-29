import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/shared/models/pagination_model.dart';

/// One-state-at-a-time view of the search:
///   idle     → nothing typed yet (or input cleared)
///   loading  → request in flight
///   success  → request finished (may have 0..n results)
///   error    → request failed
enum SearchBusinessStatus { idle, loading, success, error }

class SearchBusinessController extends GetxController {
  SearchBusinessController(this._service);

  final CommunityService _service;

  static const _debounceDelay = Duration(milliseconds: 300);
  static const _pageSize = 10;
  static const _defaultErrorMessage =
      'Could not search businesses. Please try again.';

  /// Global session cache for default businesses.
  /// Persists across multiple bottom sheet openings so default businesses
  /// are shown INSTANTLY with 0ms delay and 0 network requests after the first load.
  static final List<BrowseBusinessModel> _cachedDefaultBusinesses = [];
  static PaginationMeta? _cachedDefaultMeta;

  Timer? _debounce;
  final currentQuery = ''.obs;

  final status = SearchBusinessStatus.idle.obs;
  final businesses = <BrowseBusinessModel>[].obs;
  final errorMessage = RxnString();

  /// Pagination state — exposed so the UI can show "Load more".
  final _meta = Rxn<PaginationMeta>();
  final isPaginationLoading = false.obs;

  PaginationMeta? get meta => _meta.value;
  bool get hasNextPage => _meta.value?.hasNextPage ?? false;

  bool get isIdle => status.value == SearchBusinessStatus.idle;
  bool get isLoading => status.value == SearchBusinessStatus.loading;
  bool get hasError => status.value == SearchBusinessStatus.error;
  bool get isEmpty =>
      status.value == SearchBusinessStatus.success && businesses.isEmpty;
  bool get hasResults =>
      status.value == SearchBusinessStatus.success && businesses.isNotEmpty;

  /// True once a search has produced any final state (success or error).
  /// Kept for existing UI that drives "No results" off this flag.
  bool get searchDone =>
      status.value == SearchBusinessStatus.success ||
      status.value == SearchBusinessStatus.error;

  // ── Public actions ──────────────────────────────────────────────────────

  /// Restores initial/default businesses instantly without network call or shimmer.
  void restoreDefaults() {
    _debounce?.cancel();
    currentQuery.value = '';
    errorMessage.value = null;
    if (_cachedDefaultBusinesses.isNotEmpty) {
      businesses.assignAll(_cachedDefaultBusinesses);
      _meta.value = _cachedDefaultMeta;
      status.value = SearchBusinessStatus.success;
    } else {
      _runSearch('', page: 1, isInitialDefault: true);
    }
  }

  /// Debounced entry-point wired to text-field `onChanged`.
  void onSearchChanged(String query, {bool immediate = false}) {
    _debounce?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      if (_cachedDefaultBusinesses.isNotEmpty) {
        restoreDefaults();
        return;
      }
      _runSearch('', page: 1, isInitialDefault: true);
      return;
    }

    // When searching, clear previous results to show shimmer immediately
    currentQuery.value = trimmed;
    status.value = SearchBusinessStatus.loading;
    businesses.clear();

    if (immediate) {
      _runSearch(trimmed, page: 1);
    } else {
      _debounce = Timer(_debounceDelay, () => _runSearch(trimmed, page: 1));
    }
  }

  /// Load the next page of results for the current query.
  Future<void> loadNextPage() async {
    if (!hasNextPage || isPaginationLoading.value) return;
    final nextPage = (_meta.value?.page ?? 0) + 1;
    isPaginationLoading.value = true;
    try {
      await _runSearch(currentQuery.value, page: nextPage, append: true);
    } finally {
      isPaginationLoading.value = false;
    }
  }

  /// Re-run the last query — useful for an in-UI "Try again" button.
  Future<void> retry() async {
    if (currentQuery.value.isEmpty) {
      _runSearch('', page: 1, isInitialDefault: true);
      return;
    }
    await _runSearch(currentQuery.value, page: 1);
  }

  void reset() {
    _debounce?.cancel();
    _toIdle();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  // ── Internal ────────────────────────────────────────────────────────────

  Future<void> _runSearch(
    String query, {
    required int page,
    bool append = false,
    bool isInitialDefault = false,
  }) async {
    currentQuery.value = query;
    if (!append) {
      status.value = SearchBusinessStatus.loading;
    }
    errorMessage.value = null;

    try {
      final response = await _service.searchBusinesses(
        query,
        page: page,
        limit: _pageSize,
      );

      // Discard stale responses — the user may have kept typing.
      if (query != currentQuery.value) return;

      if (append) {
        businesses.addAll(response.data);
      } else {
        businesses.assignAll(response.data);
      }
      _meta.value = response.meta;

      if (isInitialDefault ||
          (query.isEmpty && _cachedDefaultBusinesses.isEmpty)) {
        _cachedDefaultBusinesses.clear();
        _cachedDefaultBusinesses.addAll(response.data);
        _cachedDefaultMeta = response.meta;
      }

      errorMessage.value = null;
      status.value = SearchBusinessStatus.success;
    } catch (e) {
      if (query != currentQuery.value) return;
      if (!append) {
        _toError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  // ── State transitions ───────────────────────────────────────────────────

  void _toIdle() {
    currentQuery.value = '';
    businesses.clear();
    errorMessage.value = null;
    _meta.value = null;
    isPaginationLoading.value = false;
    status.value = SearchBusinessStatus.idle;
  }

  void _toError(String? message) {
    businesses.clear();
    _meta.value = null;
    errorMessage.value = (message == null || message.isEmpty)
        ? _defaultErrorMessage
        : message;
    status.value = SearchBusinessStatus.error;
  }
}
