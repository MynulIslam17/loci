



import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../core/constants/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../data/models/community/single_community_response.dart';

class MyCommunityController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  CommunityModel? _community;

  // -------------------------------------------------
  // GETTERS
  // -------------------------------------------------
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CommunityModel? get community => _community;

  // -------------------------------------------------
  // FETCH COMMUNITY
  // -------------------------------------------------
  Future<void> fetchCommunity(String communityId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.singleCommunity(communityId),
      );

      if (response.isSuccess && response.body != null) {
        final result = SingleCommunityResponse.fromJson(response.body!);
        _community = result.data;
      } else {
        _errorMessage =
            response.body?['message'] ?? "Failed to load community";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  // -------------------------------------------------
  // REFRESH
  // -------------------------------------------------
  Future<void> refreshCommunity(String communityId) async {
    await fetchCommunity(communityId);
  }
}