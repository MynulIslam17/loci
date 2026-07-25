import 'package:get/get.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

/// Fetches a community's scannable QR token on demand (e.g. from the business
/// profile's "QR" chip). Kept separate so any screen can trigger it.
class CommunityQrController extends GetxController {
  CommunityQrController(this._service);

  final CommunityService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  /// A community's QR token is stable, so it's cached per community id and
  /// served from memory on repeat taps instead of hitting the network again.
  final _cache = <String, String>{};

  /// The already-fetched token for [communityId], or null if not cached yet.
  String? cachedQr(String communityId) => _cache[communityId];

  /// Returns the QR token, or null on failure (see [errorMessage]).
  /// Pass [forceRefresh] to bypass the cache and fetch a fresh token.
  Future<String?> fetchQr(String communityId, {bool forceRefresh = false}) async {
    if (communityId.isEmpty) {
      errorMessage.value = 'No community linked to this business';
      return null;
    }

    // Serve the cached token unless a refresh is explicitly requested.
    if (!forceRefresh) {
      final cached = _cache[communityId];
      if (cached != null) return cached;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;
      final qr = await _service.getCommunityQr(communityId);
      _cache[communityId] = qr;
      return qr;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
