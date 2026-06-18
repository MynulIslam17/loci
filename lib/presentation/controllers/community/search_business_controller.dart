import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/busniess/browse_business_model.dart';
import 'package:loci/data/models/busniess/browse_business_response_model.dart';

/// One-state-at-a-time view of the search:
///   idle     → nothing typed yet (or input cleared)
///   loading  → request in flight
///   success  → request finished (may have 0..n results)
///   error    → request failed
enum SearchBusinessStatus { idle, loading, success, error }

class SearchBusinessController extends GetxController {
  static const _debounceDelay = Duration(milliseconds: 400);
  static const _defaultErrorMessage =
      'Could not search businesses. Please try again.';

  Timer? _debounce;
  String _currentQuery = '';

  SearchBusinessStatus _status = SearchBusinessStatus.idle;
  List<BrowseBusinessModel> _businesses = const [];
  String? _errorMessage;

  // ── Public state ────────────────────────────────────────────────────────
  SearchBusinessStatus get status => _status;
  List<BrowseBusinessModel> get businesses => _businesses;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;

  bool get isIdle => _status == SearchBusinessStatus.idle;
  bool get isLoading => _status == SearchBusinessStatus.loading;
  bool get hasError => _status == SearchBusinessStatus.error;
  bool get isEmpty =>
      _status == SearchBusinessStatus.success && _businesses.isEmpty;
  bool get hasResults =>
      _status == SearchBusinessStatus.success && _businesses.isNotEmpty;

  /// True once a search has produced any final state (success or error).
  /// Kept for existing UI that drives "No results" off this flag.
  bool get searchDone =>
      _status == SearchBusinessStatus.success ||
      _status == SearchBusinessStatus.error;

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
    if (_currentQuery.isEmpty) return;
    await _runSearch(_currentQuery);
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
    _currentQuery = query;
    _status = SearchBusinessStatus.loading;
    _errorMessage = null;
    update();

    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.searchBusinesses(query),
      );

      // Discard stale responses — the user may have kept typing.
      if (query != _currentQuery) return;

      if (response.isSuccess && response.body is Map<String, dynamic>) {
        final parsed = BrowseBusinessResponseModel.fromJson(
          response.body as Map<String, dynamic>,
        );
        _toSuccess(parsed.data);
      } else {
        _toError(response.errorMessage);
      }
    } catch (e) {
      if (query != _currentQuery) return;
      _toError(e.toString());
    }
  }

  // ── State transitions (each one ends in update()) ───────────────────────

  void _toIdle() {
    _currentQuery = '';
    _businesses = const [];
    _errorMessage = null;
    _status = SearchBusinessStatus.idle;
    update();
  }

  void _toSuccess(List<BrowseBusinessModel> results) {
    _businesses = results;
    _errorMessage = null;
    _status = SearchBusinessStatus.success;
    update();
  }

  void _toError(String? message) {
    _businesses = const [];
    _errorMessage =
        (message == null || message.isEmpty) ? _defaultErrorMessage : message;
    _status = SearchBusinessStatus.error;
    update();
  }
}
