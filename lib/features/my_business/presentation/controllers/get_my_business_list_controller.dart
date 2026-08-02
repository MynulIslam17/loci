import 'package:get/get.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';

class GetMyBusinessController extends GetxController {
  GetMyBusinessController(this._service);

  final MyBusinessService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final RxnString errorMessage = RxnString();
  final RxBool isBusinessOwner = false.obs;
  final RxList<BusinessModel> businessList = <BusinessModel>[].obs;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  RxBool get isLoading => _fetch.initialLoading;

  Future<void> getMyBusinesses({String? category, bool isRefresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    _fetch.beginFirstPage(isRefresh: isRefresh);
    errorMessage.value = null;

    try {
      businessList.assignAll(
        await _service.getMyBusinesses(category: category),
      );
      _fetch.endFirstPage();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (!hasFetched) businessList.clear();
      _fetch.endFirstPage(markFetched: hasFetched);
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
