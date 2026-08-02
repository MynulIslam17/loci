import 'package:get/get.dart';

/// Tracks whether a business tab list was loaded at least once (in-memory cache).
mixin ExploreTabListCache on GetxController {
  final RxBool isRefreshing = false.obs;

  final RxnString _cachedBusinessId = RxnString();
  final RxnString _cachedSearchQuery = RxnString();

  bool isCachedFor(String businessId, {String search = ''}) {
    return _cachedBusinessId.value == businessId &&
        (_cachedSearchQuery.value ?? '') == search;
  }

  /// Last loaded business differs from [businessId] (e.g. opened another profile).
  bool businessChanged(String businessId) {
    final cached = _cachedBusinessId.value;
    return cached != null && cached != businessId;
  }

  void markCached(String businessId, {String search = ''}) {
    _cachedBusinessId.value = businessId;
    _cachedSearchQuery.value = search;
  }

  void clearTabCache() {
    _cachedBusinessId.value = null;
    _cachedSearchQuery.value = null;
  }

  /// True while the first successful load for [businessId] has not completed.
  bool showExploreInitialLoader(
    String businessId, {
    String? errorMessage,
    String search = '',
  }) {
    return !isCachedFor(businessId, search: search) && errorMessage == null;
  }

  /// True when load finished successfully and the list is empty.
  bool showExploreEmptyState(
    String businessId, {
    required bool isEmpty,
    required bool isLoading,
    String? errorMessage,
    String search = '',
  }) {
    return isCachedFor(businessId, search: search) &&
        isEmpty &&
        !isLoading &&
        !isRefreshing.value &&
        errorMessage == null;
  }

  /// Sets [isLoading] / [isRefreshing] so pull-to-refresh keeps the list visible.
  void beginExploreFetch({
    required RxBool isLoading,
    required bool forceRefresh,
    required String businessId,
    String? errorMessage,
    String search = '',
  }) {
    final initial = showExploreInitialLoader(
      businessId,
      errorMessage: errorMessage,
      search: search,
    );
    if (initial) {
      isLoading.value = true;
      isRefreshing.value = false;
    } else if (forceRefresh) {
      isRefreshing.value = true;
      isLoading.value = false;
    } else {
      isLoading.value = true;
      isRefreshing.value = false;
    }
  }

  void endExploreFetch({required RxBool isLoading}) {
    isLoading.value = false;
    isRefreshing.value = false;
  }
}
