import 'package:get/get.dart';
import 'package:loci/features/community/data/models/single_community_response.dart';
import 'package:loci/features/community/domain/services/community_service.dart';

class MyCommunityController extends GetxController {
  MyCommunityController(this._service);

  final CommunityService _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  final community = Rxn<CommunityModel>();

  // -------------------------------------------------
  // FETCH COMMUNITY
  // -------------------------------------------------
  Future<void> fetchCommunity(String communityId) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      community.value = await _service.getSingleCommunity(communityId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------------------------------
  // REFRESH
  // -------------------------------------------------
  Future<void> refreshCommunity(String communityId) async {
    await fetchCommunity(communityId);
  }
}
