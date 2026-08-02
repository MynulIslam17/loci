import 'package:get/get.dart';
import 'package:loci/features/raffles/data/models/raffle_detail_model.dart';
import 'package:loci/features/raffles/domain/services/raffles_service.dart';

class RaffleDetailsController extends GetxController {
  RaffleDetailsController(this._service);

  final RafflesService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<RaffleDetailsModel> _raffleDetails = Rxn<RaffleDetailsModel>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  RaffleDetailsModel? get raffleDetails => _raffleDetails.value;

  /// Fetch raffle details by ID
  Future<void> fetchRaffleDetails(String raffleId) async {
    _isLoading.value = true;
    _errorMessage.value = null;
    _raffleDetails.value = null;

    try {
      _raffleDetails.value = await _service.getRaffleDetails(raffleId);
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh (pull-to-refresh use)
  Future<void> refreshRaffleDetails(String raffleId) async {
    await fetchRaffleDetails(raffleId);
  }

  /// Toggle participation locally
  void updateParticipation(bool isParticipating) {
    final current = _raffleDetails.value;
    if (current == null) return;

    int updatedCount = current.participantCount;

    if (isParticipating) {
      updatedCount += 1;
    } else {
      updatedCount -= 1;
      if (updatedCount < 0) updatedCount = 0;
    }

    _raffleDetails.value = current.copyWith(
      isParticipating: isParticipating,
      participantCount: updatedCount,
    );
  }

  /// Mark task completed locally
  void updateTaskCompletion(int index, bool isCompleted) {
    final current = _raffleDetails.value;
    if (current == null) return;

    final updatedTasks = List.of(current.tasks);

    if (index >= 0 && index < updatedTasks.length) {
      updatedTasks[index] = updatedTasks[index].copyWith(
        isCompleted: isCompleted,
      );

      _raffleDetails.value = current.copyWith(tasks: updatedTasks);
    }
  }
}
