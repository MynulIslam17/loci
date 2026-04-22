import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/data/models/raffles/raffles_details_model.dart';
import '../../../core/constants/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/date_parser.dart';
import '../../../data/models/explore_activity/raffle_update_request_model.dart';
import '../../../data/models/explore_activity/task_model.dart';
import '../../../data/models/raffles/raffles_model.dart';

class RaffleEditController extends GetxController {
  // ── Text Controllers ────────────────────────────────────────────────────────
  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final maxSupplyController = TextEditingController();
  final dateController = TextEditingController();
  final raffleBundleNameTEController = TextEditingController();

  // ── State ───────────────────────────────────────────────────────────────────
  DateTime? startDate;
  DateTime? endDate;
  File? bannerImage;
  File? couponFile;
  String? existingCouponUrl;
  bool removeCoupon = false;
  bool isPublic = true;
  List<RaffleTaskModel> tasks = [];

  // ── Initial snapshot ────────────────────────────────────────────────────────
  RaffleModel? _initialRaffle;
  List<RaffleTaskModel> _initialTasks = [];
  bool _initialIsPublic = true;

  RaffleModel? get initialRaffle => _initialRaffle;

  // ── Loading / Error ─────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _bindListeners();
  }

  @override
  void onClose() {
    titleController.dispose();
    detailsController.dispose();
    maxSupplyController.dispose();
    dateController.dispose();
    raffleBundleNameTEController.dispose();
    super.onClose();
  }

  // ── Seeding ─────────────────────────────────────────────────────────────────
  void setData(RaffleDetailsModel details) {
    final raffle = details.raffleModel;
    _initialRaffle = raffle;
    _initialIsPublic = details.isPublic;
    _initialTasks = List.from(details.tasks);

    titleController.text = raffle.title;
    detailsController.text = raffle.description;
    maxSupplyController.text = raffle.maxSupply.toString();
    raffleBundleNameTEController.text = raffle.bundleName;
    isPublic = details.isPublic;
    existingCouponUrl = raffle.rafflePrizeImage;
    tasks = List.from(details.tasks);
    startDate = DateTime.parse(raffle.startDate).toLocal();
    endDate = DateTime.parse(raffle.endDate).toLocal();

    _updateDateText();
    update();
  }

  // ── Dirty Check ─────────────────────────────────────────────────────────────
  bool _tasksChanged() {
    final initialIds = _initialTasks.map((e) => e.activity?.id ?? '').toSet();
    final currentIds = tasks.map((e) => e.activity?.id ?? '').toSet();
    return initialIds.join(',') != currentIds.join(',');
  }

  bool hasChanged() {
    if (_initialRaffle == null) return false;

    final initialStart = DateTime.tryParse(
      _initialRaffle!.startDate,
    )?.toLocal();
    final initialEnd = DateTime.tryParse(_initialRaffle!.endDate)?.toLocal();

    final dateChanged =
        startDate?.year != initialStart?.year ||
        startDate?.month != initialStart?.month ||
        startDate?.day != initialStart?.day ||
        endDate?.year != initialEnd?.year ||
        endDate?.month != initialEnd?.month ||
        endDate?.day != initialEnd?.day;

    return titleController.text != _initialRaffle!.title ||
        detailsController.text != _initialRaffle!.description ||
        maxSupplyController.text != _initialRaffle!.maxSupply.toString() ||
        raffleBundleNameTEController.text != _initialRaffle!.bundleName ||
        isPublic != _initialIsPublic ||
        _tasksChanged() ||
        dateChanged ||
        bannerImage != null ||
        couponFile != null ||
        removeCoupon;
  }

  // ── Mutations ────────────────────────────────────────────────────────────────
  void updateDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    _updateDateText();
    update();
  }

  void addTask(TaskModel task) {
    final alreadyAdded = tasks.any((e) => e.activity?.id == task.id);
    if (alreadyAdded) return;

    final raffleTask = RaffleTaskModel(
      routeActivity: task.activityType == "route"
          ? TaskActivityModel(
              id: task.id,
              banner: task.banner,
              title: task.title,
              details: task.details,
            )
          : null,
      eventActivity: task.activityType == "event"
          ? TaskActivityModel(
              id: task.id,
              banner: task.banner,
              title: task.title,
              details: task.details,
            )
          : null,
      order: tasks.length + 1,
      isCompleted: false,
    );

    tasks.add(raffleTask);
    update();
  }

  void removeTask(String id) {
    tasks.removeWhere((e) => e.activity?.id == id);
    update();
  }

  void setBanner(File file) {
    bannerImage = file;
    update();
  }

  void setCoupon(File file) {
    couponFile = file;
    removeCoupon = false;
    update();
  }

  void togglePublic(bool v) {
    isPublic = v;
    update();
  }

  void removeCouponFile() {
    couponFile = null;
    existingCouponUrl = null;
    removeCoupon = true;
    update();
  }

  // ── Build Payload ────────────────────────────────────────────────────────────
  RaffleUpdateRequest buildRequest() {
    final r = _initialRaffle!;

    return RaffleUpdateRequest(
      raffleId: r.id,
      title: titleController.text != r.title ? titleController.text : null,
      description: detailsController.text != r.description
          ? detailsController.text
          : null,
      maxSupply: int.tryParse(maxSupplyController.text) != r.maxSupply
          ? int.tryParse(maxSupplyController.text)
          : null,
      startDate: startDate?.toUtc().toIso8601String() != r.startDate
          ? startDate?.toUtc().toIso8601String()
          : null,
      endDate: endDate?.toUtc().toIso8601String() != r.endDate
          ? endDate?.toUtc().toIso8601String()
          : null,
      isPublic: isPublic != _initialIsPublic ? isPublic : null,
      raffleBundleName: raffleBundleNameTEController.text != r.bundleName
          ? raffleBundleNameTEController.text
          : null,
      bannerFile: bannerImage,
      rafflePrizeImageFile: couponFile,
      removeCoupon: removeCoupon ? true : null,
      tasks: _tasksChanged() ? tasks : null,
    );
  }

  // ── API Call ─────────────────────────────────────────────────────────────────
  Future<bool> updateRaffles(RaffleUpdateRequest request) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      final fields = request.toFields();
      final response = await Get.find<NetworkCaller>().multipartRequest(
        url: AppUrl.rafflesDetails(request.raffleId),
        method: "PATCH",
        fields: fields.isNotEmpty ? fields : null,
        files: request.toFiles(),
      );

      _isLoading = false;

      if (response.isSuccess) {
        update();
        return true;
      }

      _errorMessage = response.errorMessage ?? "Update failed";
      update();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "An unexpected error occurred: $e";
      update();
      return false;
    }
  }

  // ── Private Helpers ──────────────────────────────────────────────────────────
  void _updateDateText() {
    if (startDate == null || endDate == null) return;
    dateController.text =
        "${DateParserHelper.shortDate(startDate!)} - ${DateParserHelper.shortDate(endDate!)}";
  }

  void _bindListeners() {
    for (final c in [
      titleController,
      detailsController,
      maxSupplyController,
      raffleBundleNameTEController,
    ]) {
      c.addListener(() => update());
    }
  }
}
