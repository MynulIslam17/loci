import 'dart:async';

import 'package:get/get.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
import 'package:loci/features/my_business/data/models/my_business_list_model.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';

class GetMyBusinessController extends GetxController {
  GetMyBusinessController(this._service, {AuthController? auth})
    : _authOverride = auth;

  final MyBusinessService _service;
  final AuthController? _authOverride;
  late final AuthController _auth;
  Worker? _roleWorker;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final RxnString errorMessage = RxnString();
  final RxBool isBusinessOwner = false.obs;
  final RxList<BusinessModel> businessList = <BusinessModel>[].obs;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  RxBool get isLoading => _fetch.initialLoading;

  Future<void> getMyBusinesses({
    String? category,
    bool isRefresh = false,
    bool isCategoryChange = false,
  }) async {
    if (isInitialLoading || isRefreshing) return;

    if (isCategoryChange) {
      businessList.clear();
      _fetch.initialLoading.value = true;
      _fetch.refreshing.value = false;
      _fetch.hasFetched.value = false;
    } else {
      _fetch.beginFirstPage(isRefresh: isRefresh);
    }
    errorMessage.value = null;
    // Pull-to-refresh also re-checks the role (an approval may have landed).
    if (isRefresh) unawaited(_auth.refreshUser());

    try {
      businessList.assignAll(
        await _service.getMyBusinesses(category: category),
      );
      _fetch.endFirstPage();
      // Owning a business is proof enough to show it, even before the stored
      // role catches up — and a reason to refresh that role now.
      if (businessList.isNotEmpty && !isBusinessOwner.value) {
        isBusinessOwner.value = true;
        if (!_auth.isBusinessOwner) unawaited(_auth.refreshUser());
      }
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
    _auth = _authOverride ?? Get.find<AuthController>();
    isBusinessOwner.value = _auth.isBusinessOwner;

    // React to role changes while the screen is open (claim approved).
    _roleWorker = ever<String?>(_auth.roleRx, (String? role) {
      if (role == 'business_owner') {
        if (!isBusinessOwner.value) {
          isBusinessOwner.value = true;
          getMyBusinesses();
        }
      } else if (businessList.isEmpty) {
        isBusinessOwner.value = false;
      }
    });

    // Load for everyone: a member whose claim was just approved still has a
    // stale role locally, but the server already lists their business.
    getMyBusinesses();
    unawaited(_auth.refreshUser());
  }

  @override
  void onClose() {
    _roleWorker?.dispose();
    super.onClose();
  }
}
