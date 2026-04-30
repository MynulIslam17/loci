import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/core/utils/show_snackbar.dart';

class SaveBusinessController extends GetxController {
  String? _loadingId;
  String? _errorMessage;
  String? _successMessage;

  String? get loadingId => _loadingId;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool isLoading(String id) => _loadingId == id;

  Future<bool> saveBusiness(String businessId) async {
    _loadingId = businessId;
    _errorMessage = null;
    _successMessage = null;
    update();

    try {
      final NetworkResponse response =
      await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.addBusinessToSaveList,
        body: {"businessId": businessId},
      );

      if (response.isSuccess && response.body != null) {
        _successMessage =
            response.body!['message'] ?? "Saved successfully";

        SnackbarService.success(_successMessage!);

        return true;
      } else {
        _errorMessage =
            response.body?['message'] ?? "Failed to save business";

        SnackbarService.error(_errorMessage!);

        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();

      SnackbarService.error(_errorMessage!);

      return false;
    } finally {
      _loadingId = null;
      update();
    }
  }

  void reset() {
    _loadingId = null;
    _errorMessage = null;
    _successMessage = null;
    update();
  }
}