import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/raffles/data/models/raffles_details_model.dart';
import 'package:loci/features/raffles/data/models/raffles_model.dart';
import 'package:loci/features/explore_activity/data/models/raffle_update_request_model.dart';
import 'package:loci/features/explore_activity/data/models/task_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class RaffleEditController extends GetxController {
  RaffleEditController(this._service);

  final ExploreActivityService _service;

  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final maxSupplyController = TextEditingController();
  final dateController = TextEditingController();
  final raffleBundleNameTEController = TextEditingController();

  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final Rxn<File> bannerImage = Rxn<File>();
  final Rxn<File> couponFile = Rxn<File>();
  final RxnString existingCouponUrl = RxnString();
  final RxBool removeCoupon = false.obs;
  final RxBool isPublic = true.obs;
  final RxList<RaffleTaskModel> tasks = <RaffleTaskModel>[].obs;

  /// Bumps when text fields change so Obx rebuilds for hasChanged().
  final RxInt formVersion = 0.obs;

  RaffleModel? _initialRaffle;
  List<RaffleTaskModel> _initialTasks = [];
  bool _initialIsPublic = true;

  RaffleModel? get initialRaffle => _initialRaffle;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

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

  void setData(RaffleDetailsModel details) {
    final raffle = details.raffleModel;
    _initialRaffle = raffle;
    _initialIsPublic = details.isPublic;
    _initialTasks = List.from(details.tasks);

    titleController.text = raffle.title;
    detailsController.text = raffle.description;
    maxSupplyController.text = raffle.maxSupply.toString();
    raffleBundleNameTEController.text = raffle.bundleName;
    isPublic.value = details.isPublic;
    existingCouponUrl.value = raffle.rafflePrizeImage;
    tasks.assignAll(details.tasks);
    startDate.value = DateTime.parse(raffle.startDate).toLocal();
    endDate.value = DateTime.parse(raffle.endDate).toLocal();

    _updateDateText();
    formVersion.value++;
  }

  bool _tasksChanged() {
    final initialIds = _initialTasks.map((e) => e.activity?.id ?? '').toSet();
    final currentIds = tasks.map((e) => e.activity?.id ?? '').toSet();
    return initialIds.join(',') != currentIds.join(',');
  }

  bool hasChanged() {
    formVersion.value; // ensure Obx tracks text-driven changes
    if (_initialRaffle == null) return false;

    final initialStart = DateTime.tryParse(
      _initialRaffle!.startDate,
    )?.toLocal();
    final initialEnd = DateTime.tryParse(_initialRaffle!.endDate)?.toLocal();

    final dateChanged =
        startDate.value?.year != initialStart?.year ||
        startDate.value?.month != initialStart?.month ||
        startDate.value?.day != initialStart?.day ||
        endDate.value?.year != initialEnd?.year ||
        endDate.value?.month != initialEnd?.month ||
        endDate.value?.day != initialEnd?.day;

    return titleController.text != _initialRaffle!.title ||
        detailsController.text != _initialRaffle!.description ||
        maxSupplyController.text != _initialRaffle!.maxSupply.toString() ||
        raffleBundleNameTEController.text != _initialRaffle!.bundleName ||
        isPublic.value != _initialIsPublic ||
        _tasksChanged() ||
        dateChanged ||
        bannerImage.value != null ||
        couponFile.value != null ||
        removeCoupon.value;
  }

  void updateDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    _updateDateText();
  }

  void addTask(TaskModel task) {
    bool alreadyAdded = tasks.any((e) => e.activity?.id == task.id);
    if (alreadyAdded) {
      SnackbarService.warning('Task already added');
      return;
    }

    final raffleTask = RaffleTaskModel(
      routeActivity: task.activityType == 'route'
          ? TaskActivityModel(
              id: task.id,
              banner: task.banner,
              title: task.title,
              details: task.details,
            )
          : null,
      eventActivity: task.activityType == 'event'
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
    Get.back();
  }

  void removeTask(String id) {
    tasks.removeWhere((e) => e.activity?.id == id);
  }

  void setBanner(File file) {
    bannerImage.value = file;
  }

  void setCoupon(File file) {
    couponFile.value = file;
    removeCoupon.value = false;
  }

  void togglePublic(bool v) {
    isPublic.value = v;
  }

  void removeCouponFile() {
    couponFile.value = null;
    existingCouponUrl.value = null;
    removeCoupon.value = true;
  }

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
      startDate: startDate.value?.toUtc().toIso8601String() != r.startDate
          ? startDate.value?.toUtc().toIso8601String()
          : null,
      endDate: endDate.value?.toUtc().toIso8601String() != r.endDate
          ? endDate.value?.toUtc().toIso8601String()
          : null,
      isPublic: isPublic.value != _initialIsPublic ? isPublic.value : null,
      raffleBundleName: raffleBundleNameTEController.text != r.bundleName
          ? raffleBundleNameTEController.text
          : null,
      bannerFile: bannerImage.value,
      rafflePrizeImageFile: couponFile.value,
      removeCoupon: removeCoupon.value ? true : null,
      tasks: _tasksChanged() ? tasks.toList() : null,
    );
  }

  Future<bool> updateRaffles(RaffleUpdateRequest request) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      await _service.updateRaffle(request);
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  void _updateDateText() {
    if (startDate.value == null || endDate.value == null) return;
    dateController.text =
        '${DateParserHelper.shortDate(startDate.value!)} - ${DateParserHelper.shortDate(endDate.value!)}';
  }

  void _bindListeners() {
    for (final c in [
      titleController,
      detailsController,
      maxSupplyController,
      raffleBundleNameTEController,
    ]) {
      c.addListener(() => formVersion.value++);
    }
  }
}
