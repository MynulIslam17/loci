import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/utils/show_snackbar.dart';

import '../../../data/models/busniess/my_business_model.dart';
import '../auth/auth_controller.dart';

class GetMyBusinessController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  bool isBusinessOwner=false;

  bool isLoading = false;
  List<BusinessModel> businesses = [];

  void _setLoading(bool value) {
    isLoading = value;
    update();
  }

  Future<void> getMyBusinesses() async {
    _setLoading(true);

    try {
      final response = await _network.getRequest(
        url: AppUrl.myBusiness,
      );

      if (!response.isSuccess || response.body == null) {
        SnackbarService.error(
          response.errorMessage ?? "Failed to load businesses",
        );
        return;
      }

      final model = MyBusinessResponseModel.fromJson(response.body!);

      businesses = model.data;
    } catch (e) {
      SnackbarService.error("Something went wrong");
    } finally {
      _setLoading(false);
      update();
    }
  }

  @override
  void onInit() {
    super.onInit();

    final authController = Get.find<AuthController>();

    isBusinessOwner = authController.userModel?.role == "business_owner";

    if (isBusinessOwner) {
      getMyBusinesses();
    }
  }
}