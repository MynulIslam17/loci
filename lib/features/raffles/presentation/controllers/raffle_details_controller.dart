import 'package:get/get.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/raffles/data/models/raffle_detail_model.dart';
import 'package:loci/features/raffles/domain/services/raffles_service.dart';
import 'package:loci/features/raffles/presentation/controllers/raffle_list_controller.dart';

class RaffleDetailsController extends GetxController {
  RaffleDetailsController(this._service);

  final RafflesService _service;

  final RxBool _isLoading = false.obs;
  final RxBool _isJoining = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<RaffleDetailsModel> _raffleDetails = Rxn<RaffleDetailsModel>();

  bool get isLoading => _isLoading.value;
  bool get isJoining => _isJoining.value;
  String? get errorMessage => _errorMessage.value;
  RaffleDetailsModel? get raffleDetails => _raffleDetails.value;

  /// Fetch raffle details by ID
  Future<void> fetchRaffleDetails(
    String raffleId, {
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading.value = true;
      _raffleDetails.value = null;
    }
    _errorMessage.value = null;

    try {
      _raffleDetails.value = await _service.getRaffleDetails(raffleId);
    } catch (e) {
      _errorMessage.value = AppErrorMessages.sanitize(e);
    } finally {
      if (!silent) _isLoading.value = false;
    }
  }

  /// Refresh (pull-to-refresh) — keeps current UI visible.
  Future<void> refreshRaffleDetails(String raffleId) async {
    await fetchRaffleDetails(raffleId, silent: true);
  }

  /// Join / Participate in the raffle via POST /raffles/:id/participate
  Future<bool> joinRaffle(String raffleId) async {
    if (_isJoining.value) return false;
    _isJoining.value = true;

    try {
      final updated = await _service.participateInRaffle(raffleId);
      final prev = _raffleDetails.value;

      List<RaffleTaskModel> mergedTasks = updated.tasks;
      if (prev != null) {
        mergedTasks = updated.tasks.map((newT) {
          final oldT = prev.tasks.firstWhereOrNull(
            (t) =>
                (t.activity?.id.isNotEmpty ?? false) &&
                (t.activity?.id == newT.activity?.id || t.order == newT.order),
          );
          if (oldT != null && (newT.activity?.title.isEmpty ?? true)) {
            return newT.copyWith(
              routeActivity: oldT.routeActivity,
              eventActivity: oldT.eventActivity,
            );
          }
          return newT;
        }).toList();
      }

      final merged = updated.copyWith(
        isParticipating: true,
        tasks: mergedTasks,
        sponsor: (updated.sponsor.name.isEmpty && prev != null)
            ? prev.sponsor
            : updated.sponsor,
      );
      _raffleDetails.value = merged;

      // Update the item in the active raffles list
      if (Get.isRegistered<RaffleListController>()) {
        Get.find<RaffleListController>().markRaffleEntered(raffleId);
      }

      if (merged.voucherCode != null && merged.voucherCode!.isNotEmpty) {
        SnackbarService.success(
          'You have entered the raffle! Voucher code issued.',
        );
      } else {
        SnackbarService.success('You have successfully entered the raffle!');
      }
      return true;
    } catch (e) {
      SnackbarService.error(AppErrorMessages.sanitize(e));
      return false;
    } finally {
      _isJoining.value = false;
    }
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
      _raffleDetails.refresh();
    }
  }

  /// Marks the task linked to [activityId] as completed.
  void markTaskCompletedByActivityId(String activityId) {
    if (activityId.isEmpty) return;
    final current = _raffleDetails.value;
    if (current == null) return;

    final index = current.tasks.indexWhere(
      (task) => task.activity?.id == activityId,
    );
    if (index < 0) return;
    updateTaskCompletion(index, true);
  }
}
