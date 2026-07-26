import 'package:get/get.dart';
import 'package:loci/features/raffles/data/models/raffles_details_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class BusinessRaffleDetailsController extends GetxController {
  BusinessRaffleDetailsController(this._service);

  final ExploreActivityService _service;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<RaffleDetailsModel> raffleDetails = Rxn<RaffleDetailsModel>();

  Future<void> fetchRaffleDetails(String raffleId) async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      raffleDetails.value = await _service.getRaffleDetails(raffleId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDetails(String raffleId) async {
    await fetchRaffleDetails(raffleId);
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
