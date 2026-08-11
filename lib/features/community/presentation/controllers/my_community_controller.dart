import 'package:get/get.dart';
import 'package:loci/features/community/data/models/single_community_response.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

/// UI → [MyCommunityController] → [CommunityService] → repository → API.
class MyCommunityController extends GetxController {
  MyCommunityController(this._service);

  final CommunityService _service;

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final errorMessage = RxnString();

  final community = Rxn<CommunityModel>();

  String? _activeFetchCommunityId;

  /// Call before loading a different community so the UI does not show stale data.
  void prepareForLoad(String communityId) {
    if (community.value?.id == communityId) return;
    _activeFetchCommunityId = communityId;
    community.value = null;
    errorMessage.value = null;
    isRefreshing.value = false;
    isLoading.value = true;
  }

  Future<void> fetchCommunity(String communityId) async {
    _activeFetchCommunityId = communityId;

    final switchingCommunity =
        community.value != null && community.value!.id != communityId;
    if (switchingCommunity) {
      community.value = null;
      errorMessage.value = null;
    }

    final isInitialLoad = community.value == null;
    try {
      if (isInitialLoad) {
        isLoading.value = true;
        isRefreshing.value = false;
      } else {
        isRefreshing.value = true;
      }
      errorMessage.value = null;

      final loaded = await _service.getSingleCommunity(communityId);
      if (_activeFetchCommunityId != communityId) return;

      community.value = loaded;
    } catch (e) {
      if (_activeFetchCommunityId != communityId) return;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (_activeFetchCommunityId == communityId) {
        isLoading.value = false;
        isRefreshing.value = false;
      }
    }
  }

  // -------------------------------------------------
  // REFRESH
  // -------------------------------------------------
  Future<void> refreshCommunity(String communityId) async {
    await fetchCommunity(communityId);
  }

  void updateMemberCount(int count) {
    final current = community.value;
    if (current == null) return;
    community.value = CommunityModel(
      id: current.id,
      business: current.business,
      name: current.name,
      description: current.description,
      qrCode: current.qrCode,
      memberCount: count,
      isActive: current.isActive,
      ownerUserId: current.ownerUserId,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt,
    );
  }
}
