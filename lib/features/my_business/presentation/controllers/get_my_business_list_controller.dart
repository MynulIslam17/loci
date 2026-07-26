import 'package:get/get.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
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

  /// Updates one list row from the profile screen — avoids refetching `/businesses/me`.
  void applyProfileSnapshot(BusinessProfileModel profile) {
    final index = businessList.indexWhere((b) => b.id == profile.id);
    if (index == -1) return;

    businessList[index] = businessList[index].copyWith(
      name: profile.name,
      category: profile.category,
      description: profile.description,
      logo: profile.logo,
    );
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
