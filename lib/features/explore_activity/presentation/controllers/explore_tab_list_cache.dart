/// Tracks whether a business tab list was loaded at least once (in-memory cache).
mixin ExploreTabListCache {
  String? _cachedBusinessId;
  bool _hasLoadedOnce = false;

  bool isCachedFor(String businessId) =>
      _hasLoadedOnce && _cachedBusinessId == businessId;

  void markCached(String businessId) {
    _cachedBusinessId = businessId;
    _hasLoadedOnce = true;
  }

  void clearTabCache() {
    _cachedBusinessId = null;
    _hasLoadedOnce = false;
  }
}
