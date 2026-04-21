import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';
import '../../../data/models/raffles/raffles_details_model.dart';

class BusinessRaffleDetailsController extends GetxController {
  /// ===== STATE VARIABLES =====
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RaffleDetailsModel? _raffleDetails;
  RaffleDetailsModel? get raffleDetails => _raffleDetails;

  /// ===== FETCH DATA =====
  Future<void> fetchRaffleDetails(String raffleId) async {

    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final NetworkResponse response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.rafflesDetails(raffleId),
      );

      if (response.isSuccess && response.body != null) {
        _raffleDetails = RaffleDetailsModel.fromJson(response.body!);
      } else {

        _errorMessage = response.errorMessage ?? 'Failed to fetch raffle details';
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred: ${e.toString()}";
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// ===== REFRESH DATA =====
  Future<void> refreshDetails(String raffleId) async {
    await fetchRaffleDetails(raffleId);
  }


  /// ===== CLEANUP =====
  void clearDetails() {
    _raffleDetails = null;
    _errorMessage = null;
    _isLoading = false;
    update();
  }

  @override
  void onClose() {
    clearDetails();
    super.onClose();
  }
}