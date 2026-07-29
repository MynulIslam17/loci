import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/acitvity_validator.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/raffles/data/models/raffle_detail_model.dart';
import 'package:loci/features/raffles/data/models/raffle_list_model.dart';
import 'package:loci/features/explore_activity/data/models/update_raffle_request_model.dart';
import 'package:loci/features/explore_activity/data/models/activity_task_search_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffle_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/explore_activity_edit_form.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_task_sheet.dart';

class RaffleEditController extends GetxController {
  RaffleEditController(this._service);

  final ExploreActivityService _service;
  BusinessRaffleDetailsController get _details =>
      Get.find<BusinessRaffleDetailsController>();

  final formKey = GlobalKey<FormState>();

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

  late String raffleId;

  bool get isLoadingDetails => _details.isLoading.value;
  String? get detailsError => _details.errorMessage.value;
  RaffleDetailsModel? get raffleDetails => _details.raffleDetails.value;

  String? get couponImageUrl {
    if (removeCoupon.value) return null;
    if (couponFile.value != null) return null;
    return existingCouponUrl.value;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    raffleId = args?['raffleId']?.toString() ?? '';
    _bindListeners();
  }

  @override
  void onReady() {
    super.onReady();
    loadDetails();
  }

  Future<void> loadDetails() async {
    await _details.fetchRaffleDetails(raffleId);
    final details = _details.raffleDetails.value;
    if (details != null) {
      setData(details);
    }
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
    if (_initialTasks.length != tasks.length) return true;
    for (var i = 0; i < tasks.length; i++) {
      final before = _initialTasks[i].activity?.id ?? '';
      final after = tasks[i].activity?.id ?? '';
      if (before != after) return true;
    }
    return false;
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

    return editFieldChanged(titleController.text, _initialRaffle!.title) ||
        editFieldChanged(
          detailsController.text,
          _initialRaffle!.description,
        ) ||
        editFieldChanged(
          maxSupplyController.text,
          _initialRaffle!.maxSupply.toString(),
        ) ||
        editFieldChanged(
          raffleBundleNameTEController.text,
          _initialRaffle!.bundleName,
        ) ||
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
    formVersion.value++;
  }

  void addTask(TaskModel task) {
    final taskId = task.id;
    if (taskId.isEmpty) return;

    final alreadyAdded = tasks.any((e) => e.activity?.id == taskId);
    if (alreadyAdded) {
      SnackbarService.warning('Task already added');
      return;
    }

    final type = task.activityType.toLowerCase();
    final isRoute = type.contains('route');
    final isEvent = type.contains('event') || !isRoute;

    final raffleTask = RaffleTaskModel(
      routeActivity: isRoute
          ? TaskActivityModel(
              id: taskId,
              banner: task.banner,
              title: task.title,
              details: task.details,
            )
          : null,
      eventActivity: isEvent
          ? TaskActivityModel(
              id: taskId,
              banner: task.banner,
              title: task.title,
              details: task.details,
            )
          : null,
      order: tasks.length + 1,
      isCompleted: false,
    );

    if (raffleTask.activity == null) {
      SnackbarService.error('Could not add this activity as a task');
      return;
    }

    tasks.add(raffleTask);
    formVersion.value++;
  }

  void removeTaskAt(int index) {
    if (index < 0 || index >= tasks.length) return;
    final id = tasks[index].activity?.id ?? '';
    removeTask(id);
  }

  void removeTask(String id) {
    if (id.isEmpty) return;
    final updated = tasks.where((e) => e.activity?.id != id).toList();
    for (var i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(order: i + 1);
    }
    tasks.assignAll(updated);
    formVersion.value++;
  }

  void setBanner(File file) {
    bannerImage.value = file;
    formVersion.value++;
  }

  void setCoupon(File file) {
    couponFile.value = file;
    removeCoupon.value = false;
    formVersion.value++;
  }

  void togglePublic(bool v) {
    isPublic.value = v;
    formVersion.value++;
  }

  void removeCouponFile() {
    couponFile.value = null;
    existingCouponUrl.value = null;
    removeCoupon.value = true;
    formVersion.value++;
  }

  RaffleUpdateRequest buildRequest() {
    final r = _initialRaffle!;

    // PATCH: only include fields the user changed, comparing trimmed input.
    final title = titleController.text.trim();
    final desc = detailsController.text.trim();
    final bundleName = raffleBundleNameTEController.text.trim();
    final supply = int.tryParse(maxSupplyController.text.trim());

    return RaffleUpdateRequest(
      raffleId: r.id,
      title: title != r.title ? title : null,
      description: desc != r.description ? desc : null,
      maxSupply: supply != null && supply != r.maxSupply ? supply : null,
      startDate: startDate.value?.toUtc().toIso8601String() != r.startDate
          ? startDate.value?.toUtc().toIso8601String()
          : null,
      endDate: endDate.value?.toUtc().toIso8601String() != r.endDate
          ? endDate.value?.toUtc().toIso8601String()
          : null,
      isPublic: isPublic.value != _initialIsPublic ? isPublic.value : null,
      raffleBundleName: bundleName != r.bundleName ? bundleName : null,
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

  Future<void> pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existingStart = startDate.value;
    // Prevent picking a fully-past entry period, but keep an already-started
    // raffle's range selectable so the picker never asserts on bounds.
    final firstDate = (existingStart != null && existingStart.isBefore(today))
        ? existingStart
        : today;

    final hasRange = startDate.value != null &&
        endDate.value != null &&
        !startDate.value!.isBefore(firstDate);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      initialDateRange: hasRange
          ? DateTimeRange(start: startDate.value!, end: endDate.value!)
          : null,
    );
    if (picked != null) {
      updateDateRange(picked.start, picked.end);
    }
  }

  Future<void> pickCouponFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setCoupon(File(result.files.single.path!));
    }
  }

  void openAddTaskSheet(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final businessId = args['businessId']?.toString() ??
        _details.raffleDetails.value?.sponsor.id ??
        '';
    showCreateActivityTaskSheet(
      context: context,
      businessId: businessId,
      onAddTask: addTask,
    );
  }

  Future<void> submit() async {
    final hasBanner =
        bannerImage.value != null ||
        (initialRaffle?.banner.isNotEmpty ?? false);
    final hasCoupon =
        couponFile.value != null ||
        (existingCouponUrl.value != null && removeCoupon.value == false);

    final title = titleController.text.trim();
    final desc = detailsController.text.trim();
    final maxSupply = maxSupplyController.text.trim();
    final prizeName = raffleBundleNameTEController.text.trim();

    if (!ActivityValidator.reportEditValidationFailure(
      ActivityValidator.validateRaffleEdit(
        formKey: formKey,
        title: title,
        description: desc,
        maxSupply: maxSupply,
        prizeName: prizeName,
        startDate: startDate.value,
        endDate: endDate.value,
        hasBanner: hasBanner,
        hasCoupon: hasCoupon,
        hasTasks: tasks.isNotEmpty,
      ),
    )) {
      return;
    }

    if (!ensureHasChanges(hasChanges: hasChanged())) return;

    final success = await updateRaffles(buildRequest());
    if (success) {
      Get.back(result: true);
      SnackbarService.success('Raffle updated');
    } else {
      SnackbarService.error(errorMessage.value ?? 'Update failed');
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
