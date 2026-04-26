import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/core/network/network_response.dart';

import '../../../data/models/raffles/raffles_details_model.dart';



class RaffleDetailsController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  RaffleDetailsModel? _raffleDetails;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RaffleDetailsModel? get raffleDetails => _raffleDetails;

  /// Fetch raffle details by ID
  Future<void> fetchRaffleDetails(String raffleId) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(url: AppUrl.rafflesDetails(raffleId));

      if (response.isSuccess && response.body != null) {

        _raffleDetails = RaffleDetailsModel.fromJson(response.body!);
      } else {
        _errorMessage =
            response.errorMessage ?? 'Failed to load raffle details';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// Refresh (pull-to-refresh use)
  Future<void> refreshRaffleDetails(String raffleId) async {
    await fetchRaffleDetails(raffleId);
  }

  /// Toggle participation locally
  void updateParticipation(bool isParticipating) {
    if (_raffleDetails == null) return;

    int updatedCount = _raffleDetails!.participantCount;

    if (isParticipating) {
      updatedCount += 1;
    } else {
      updatedCount -= 1;
      if (updatedCount < 0) updatedCount = 0;
    }

    _raffleDetails = _raffleDetails!.copyWith(
      isParticipating: isParticipating,
      participantCount: updatedCount,
    );

    update();
  }

  /// Mark task completed locally
  void updateTaskCompletion(int index, bool isCompleted) {
    if (_raffleDetails == null) return;

    final updatedTasks = List.of(_raffleDetails!.tasks);

    if (index >= 0 && index < updatedTasks.length) {
      updatedTasks[index] =
          updatedTasks[index].copyWith(isCompleted: isCompleted);

      _raffleDetails = _raffleDetails!.copyWith(tasks: updatedTasks);
      update();
    }
  }
}