import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/core/utils/show_snackbar.dart';

class RemoveSavedBusinessController extends GetxController {
  String? _loadingId;

  bool isLoading(String id) => _loadingId == id;

  Future<bool> removeBusiness(String businessId) async {
    _loadingId = businessId;
    update();

    try {
      final NetworkResponse response =
      await Get.find<NetworkCaller>().deleteRequest(
        url: AppUrl.removeSavedBusiness(businessId),
      );

      if (response.isSuccess) {
        SnackbarService.success(
          response.body?['message'] ?? "Removed successfully",
        );
        return true;
      } else {
        SnackbarService.error(
          response.body?['message'] ?? "Failed to remove",
        );
        return false;
      }
    } catch (e) {
      SnackbarService.error(e.toString());
      return false;
    } finally {
      _loadingId = null;
      update();
    }
  }
}