import 'package:get/get.dart';
import 'package:loci/features/community/data/models/single_community_response.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

class MyCommunityController extends GetxController {
  MyCommunityController(this._service);

  final CommunityService _service;

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final errorMessage = RxnString();

  final community = Rxn<CommunityModel>();

  // -------------------------------------------------
  // FETCH COMMUNITY
  // -------------------------------------------------
  Future<void> fetchCommunity(String communityId) async {
    final isInitialLoad = community.value == null;
    try {
      if (isInitialLoad) {
        isLoading.value = true;
      } else {
        isRefreshing.value = true;
      }
      errorMessage.value = null;

      community.value = await _service.getSingleCommunity(communityId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
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
