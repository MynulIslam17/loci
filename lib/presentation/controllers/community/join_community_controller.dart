import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/utils/show_snackbar.dart';

import 'all_community_controller.dart';

class JoinCommunityController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  String? _joiningId;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  ///  Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  ///  per-item loading
  bool isJoining(String id) => _joiningId == id;


  Future<bool> joinCommunity({
    required String joinId,
  }) async {
    _joiningId = joinId;
    update();

    _errorMessage = null;
    _successMessage = null;

    try {
      final response = await _network.postRequest(
        url: AppUrl.joinCommunity,
        body: {
          "qrCode": joinId,
        },
      );

      if (response.isSuccess) {
        _successMessage = response.body?["message"] ?? "Successfully joined community";
        SnackbarService.success(_successMessage!);
        update();
        Get.find<AllCommunityController>().refreshCommunities();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to join community";
        SnackbarService.error(_errorMessage!);
        update();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      SnackbarService.error(_errorMessage!);
      update();
      return false;
    } finally {
      _joiningId = null;
      update();
    }
  }
}