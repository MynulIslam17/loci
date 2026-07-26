import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

/// One-state-at-a-time view of the search:
///   idle     → nothing typed yet (or input cleared)
///   loading  → request in flight
///   success  → request finished (may have 0..n results)
///   error    → request failed
enum SearchBusinessStatus { idle, loading, success, error }

class SearchBusinessController extends GetxController {
  SearchBusinessController(this._service);

  final CommunityService _service;

  static const _debounceDelay = Duration(milliseconds: 400);
  static const _defaultErrorMessage =
      'Could not search businesses. Please try again.';

  Timer? _debounce;
  final currentQuery = ''.obs;

  final status = SearchBusinessStatus.idle.obs;
  final businesses = <BrowseBusinessModel>[].obs;
  final errorMessage = RxnString();

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

  /// Debounced entry-point wired to text-field `onChanged`.
  void onSearchChanged(String query) {
    _debounce?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _toIdle();
      return;
    }

    _debounce = Timer(_debounceDelay, () => _runSearch(trimmed));
  }

  /// Re-run the last query — useful for an in-UI "Try again" button.
  Future<void> retry() async {
    if (currentQuery.value.isEmpty) return;
    await _runSearch(currentQuery.value);
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

  Future<void> _runSearch(String query) async {
    currentQuery.value = query;
    status.value = SearchBusinessStatus.loading;
    errorMessage.value = null;

    try {
      final results = await _service.searchBusinesses(query);

      // Discard stale responses — the user may have kept typing.
      if (query != currentQuery.value) return;

      _toSuccess(results);
    } catch (e) {
      if (query != currentQuery.value) return;
      _toError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── State transitions ───────────────────────────────────────────────────

  void _toIdle() {
    currentQuery.value = '';
    businesses.clear();
    errorMessage.value = null;
    status.value = SearchBusinessStatus.idle;
  }

  void _toSuccess(List<BrowseBusinessModel> results) {
    businesses.assignAll(results);
    errorMessage.value = null;
    status.value = SearchBusinessStatus.success;
  }

  void _toError(String? message) {
    businesses.clear();
    errorMessage.value = (message == null || message.isEmpty)
        ? _defaultErrorMessage
        : message;
    status.value = SearchBusinessStatus.error;
  }
}
