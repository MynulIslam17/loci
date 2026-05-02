import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/utils/show_snackbar.dart';

import '../../../data/models/busniess/my_business_list_model.dart';
import '../auth/auth_controller.dart';

class GetMyBusinessController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();
   String ? _errorMessage;

  bool isBusinessOwner=false;

  bool isLoading = false;
  List<BusinessModel> businessList = [];

  void _setLoading(bool value) {
    isLoading = value;
    update();
  }

  String ?get errorMessage=>_errorMessage;

  Future<void> getMyBusinesses({String? category}) async {
    _errorMessage = null;
    _setLoading(true);

    try {
      final url = category != null
          ? "${AppUrl.myBusiness}?category=$category"
          : AppUrl.myBusiness;

      final response = await _network.getRequest(
        url: url,
      );

      if (!response.isSuccess || response.body == null) {
        _errorMessage = response.errorMessage ?? "Something went wrong";
        businessList = [];
        return;
      }

      final model = MyBusinessResponseModel.fromJson(response.body!);

      businessList = model.data;
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      businessList = [];
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