import 'package:get/get.dart';
import 'package:loci/features/raffles/data/models/raffle_detail_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class BusinessRaffleDetailsController extends GetxController {
  BusinessRaffleDetailsController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<RaffleDetailsModel> raffleDetails = Rxn<RaffleDetailsModel>();

  String screenTitle = '';
  String _raffleId = '';
  String _businessId = '';

  String get raffleId => _raffleId;
  String get businessId => _businessId;

  Future<void> loadFromRouteArguments() async {
    final args = Get.arguments as Map<String, dynamic>?;
    screenTitle = args?['rafflesName']?.toString() ?? '';
    _raffleId = args?['raffleId']?.toString() ?? '';
    _businessId = args?['businessId']?.toString() ?? '';
    await fetchRaffleDetails(_raffleId);
  }

  Future<void> retryLoad() => fetchRaffleDetails(_raffleId);

  Future<void> refreshDetails([String? raffleId]) =>
      fetchRaffleDetails(raffleId ?? _raffleId, silent: true);

  Future<void> fetchRaffleDetails(
    String raffleId, {
    bool silent = false,
  }) async {
    if (!silent) {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      raffleDetails.value = await _service.getRaffleDetails(raffleId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  void clearDetails() {
    raffleDetails.value = null;
    errorMessage.value = null;
    isLoading.value = false;
  }

  @override
  void onClose() {
    clearDetails();
    super.onClose();
  }
}
