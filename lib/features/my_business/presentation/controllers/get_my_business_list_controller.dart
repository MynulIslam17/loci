import 'package:get/get.dart';
import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';

class GetMyBusinessController extends GetxController {
  GetMyBusinessController(this._service);

  final MyBusinessService _service;

  final RxnString errorMessage = RxnString();

  final RxBool isBusinessOwner = false.obs;

  final RxBool isLoading = false.obs;
  final RxList<BusinessModel> businessList = <BusinessModel>[].obs;

  void _setLoading(bool value) {
    isLoading.value = value;
  }

  Future<void> getMyBusinesses({String? category}) async {
    errorMessage.value = null;
    _setLoading(true);

    try {
      businessList.assignAll(
        await _service.getMyBusinesses(category: category),
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      businessList.clear();
    } finally {
      _setLoading(false);
    }
  }

  @override
  void onInit() {
    super.onInit();

    final authController = Get.find<AuthController>();

    isBusinessOwner.value = authController.userModel?.role == 'business_owner';

    if (isBusinessOwner.value) {
      getMyBusinesses();
    }
  }
}
