import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/enums/activity_type.dart';
import 'package:loci/core/enums/routeType.dart';
import 'package:loci/core/utils/acitvity_validator.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/explore_activity/data/models/activity_task_search_model.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_raffles_list_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_list_controller.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_task_sheet.dart';
import 'package:loci/shared/widgets/location/location_models.dart';

class CreateActivityController extends GetxController {
  CreateActivityController(this._service);

  final ExploreActivityService _service;

  final formKey = GlobalKey<FormState>();

  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final personController = TextEditingController();
  final locationController = TextEditingController();
  final urlController = TextEditingController();
  final maxSupplyController = TextEditingController();
  final raffleDateController = TextEditingController();
  final couponTitleController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString message = ''.obs;

  final Rx<ActivityType> selectedCategory = ActivityType.event.obs;
  final Rxn<RouteType> selectedRouteCondition = Rxn<RouteType>();
  final RxBool isPublic = false.obs;

  /// Coordinates from the location picker (event & route only). Required on
  /// create — publish is blocked until a place is picked.
  final Rxn<double> pickedLat = Rxn<double>();
  final Rxn<double> pickedLng = Rxn<double>();

  void setPickedLocation(PickedLocation place) {
    pickedLat.value = place.lat;
    pickedLng.value = place.lng;
  }

  final Rxn<File> bannerImage = Rxn<File>();
  final Rxn<File> rafflePrizeImage = Rxn<File>();

  final Rxn<DateTime> eventDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> eventTime = Rxn<TimeOfDay>();
  final Rxn<TimeOfDay> routeOpeningTime = Rxn<TimeOfDay>();
  final Rxn<DateTimeRange> raffleRange = Rxn<DateTimeRange>();

  final RxList<TaskModel> tasks = <TaskModel>[].obs;

  String businessId = '';
  String businessName = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      businessId = args['businessId']?.toString() ?? '';
      businessName = args['businessName']?.toString() ?? '';
    }
  }

  @override
  void onReady() {
    super.onReady();
    prepareNewActivityForm();
  }

  Future<void> handlePublish(BuildContext context) async {
    final success = await publish(context);
    if (!context.mounted) return;

    if (success) {
      await _refreshListForCategory(selectedCategory.value, businessId);
      Get.back();
      SnackbarService.success(message.value);
      return;
    }

    if (message.value.isNotEmpty) {
      SnackbarService.warning(message.value);
    }
  }

  void openAddTaskSheet(BuildContext context) {
    showCreateActivityTaskSheet(
      context: context,
      businessId: businessId,
      onAddTask: (task) {
        if (isDuplicateTask(task)) {
          SnackbarService.warning('Task already added');
          return;
        }
        addTask(task);
      },
    );
  }

  Future<void> _refreshListForCategory(
    ActivityType category,
    String businessId,
  ) async {
    switch (category) {
      case ActivityType.event:
        await Get.find<BusinessEventListController>().fetchEvents(
          businessId: businessId,
          forceRefresh: true,
        );
      case ActivityType.routes:
        await Get.find<BusinessRouteListController>().fetchRoutes(
          businessId: businessId,
          forceRefresh: true,
        );
      case ActivityType.raffles:
        await Get.find<BusinessRafflesListController>().fetchRaffles(
          businessId: businessId,
          forceRefresh: true,
        );
    }
  }

  /// Clears the form when opening create activity (controller is fenix-persisted).
  void prepareNewActivityForm() {
    formKey.currentState?.reset();
    selectedCategory.value = ActivityType.event;
    isPublic.value = false;
    isLoading.value = false;
    message.value = '';

    titleController.clear();
    detailsController.clear();
    locationController.clear();
    urlController.clear();
    pickedLat.value = null;
    pickedLng.value = null;
    bannerImage.value = null;
    _clearCategorySpecificFields();
  }

  @override
  void onClose() {
    dateController.dispose();
    timeController.dispose();
    titleController.dispose();
    detailsController.dispose();
    personController.dispose();
    locationController.dispose();
    urlController.dispose();
    maxSupplyController.dispose();
    raffleDateController.dispose();
    couponTitleController.dispose();
    super.onClose();
  }

  void setBanner(File file) => bannerImage.value = file;

  void setCategory(ActivityType value) {
    if (value != selectedCategory.value) {
      _clearCategorySpecificFields();
    }
    selectedCategory.value = value;
  }

  void setRouteType(RouteType? value) => selectedRouteCondition.value = value;

  void setPublic(bool value) => isPublic.value = value;

  void addTask(TaskModel task) {
    if (tasks.any((t) => t.id == task.id)) return;
    tasks.add(task);
  }

  bool isDuplicateTask(TaskModel task) => tasks.any((t) => t.id == task.id);

  void removeTaskAt(int index) => tasks.removeAt(index);

  void clearRafflePrize() => rafflePrizeImage.value = null;

  void setRafflePrize(File file) => rafflePrizeImage.value = file;

  Future<void> pickRaffleCoupon() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result == null) return;
    final path = result.files.single.path;
    if (path == null) return;
    setRafflePrize(File(path));
  }

  Future<void> pickEventDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: DateTime.now(),
      lastDate: DateTime(2049),
    );
    if (picked == null) return;
    eventDate.value = picked;
    dateController.text = DateParserHelper.toFriendlyDate(picked);
  }

  Future<void> pickRaffleRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2049),
    );
    if (picked == null) return;
    raffleRange.value = picked;
    raffleDateController.text =
        '${DateParserHelper.shortDate(picked.start)} → '
        '${DateParserHelper.shortDate(picked.end)}';
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    if (selectedCategory.value == ActivityType.event) {
      eventTime.value = picked;
    }
    if (selectedCategory.value == ActivityType.routes) {
      routeOpeningTime.value = picked;
    }

    timeController.text = formatTime(picked);
  }

  Future<bool> publish(BuildContext context) async {
    final validationError = ActivityValidator.validateAll(
      formKey: formKey,
      bannerPath: bannerImage.value?.path,
      category: selectedCategory.value,
      eventDate: eventDate.value,
      eventTime: eventTime.value,
      routeOpeningTime: routeOpeningTime.value,
      routeType: selectedRouteCondition.value,
      raffleRange: raffleRange.value,
      hasCoupon: rafflePrizeImage.value != null,
      hasTasks: tasks.isNotEmpty,
    );

    if (validationError != null) {
      if (validationError != 'FORM_INVALID') {
        message.value = validationError;
      }
      return false;
    }

    // Event & route require coordinates — block create until a place is picked.
    if ((selectedCategory.value == ActivityType.event ||
            selectedCategory.value == ActivityType.routes) &&
        (pickedLat.value == null || pickedLng.value == null)) {
      message.value = 'Please pick a location from search';
      return false;
    }

    final body = <String, String>{
      'activityType': selectedCategory.value.toJson,
      'title': titleController.text.trim(),
      'details': detailsController.text.trim(),
      'isPublic': isPublic.value.toString(),
    };

    if (selectedCategory.value == ActivityType.raffles) {
      body['sponsor'] = businessId;
    } else {
      body['organizerBusiness'] = businessId;
    }

    final category = selectedCategory.value;

    if (category == ActivityType.event) {
      body.addAll({
        'eventDate': combineToUtcIso(eventDate.value!, eventTime.value!),
        'eventTime': eventTime.value!.format(context),
        'maxParticipants': personController.text.trim(),
        'location': locationController.text.trim(),
        'mapCoordinates[lat]': pickedLat.value!.toString(),
        'mapCoordinates[lng]': pickedLng.value!.toString(),
        if (urlController.text.trim().isNotEmpty)
          'url': urlController.text.trim(),
      });
    }

    if (category == ActivityType.routes) {
      body.addAll({
        'openingTime': routeOpeningTime.value!.format(context),
        'availabilityType': selectedRouteCondition.value?.apiValue ?? '',
        'location': locationController.text.trim(),
        'mapCoordinates[lat]': pickedLat.value!.toString(),
        'mapCoordinates[lng]': pickedLng.value!.toString(),
        if (urlController.text.trim().isNotEmpty)
          'url': urlController.text.trim(),
      });
    }

    if (category == ActivityType.raffles) {
      final tasksPayload = <Map<String, dynamic>>[];
      for (var i = 0; i < tasks.length; i++) {
        final isRoute = tasks[i].activityType.toLowerCase().contains('route');
        tasksPayload.add({
          isRoute ? 'routeActivity' : 'eventActivity': tasks[i].id,
          'order': i + 1,
        });
      }
      body.addAll({
        'startDate': raffleRange.value!.start.toUtc().toIso8601String(),
        'endDate': raffleRange.value!.end.toUtc().toIso8601String(),
        'maxSupply': maxSupplyController.text.trim(),
        'raffleBundleName': couponTitleController.text.trim(),
        'tasks': jsonEncode(tasksPayload),
      });
    }

    final url = switch (category) {
      ActivityType.event => AppUrl.createEvent,
      ActivityType.routes => AppUrl.createRoute,
      ActivityType.raffles => AppUrl.raffles,
    };

    try {
      isLoading.value = true;
      message.value = await _service.createActivity(
        url: url,
        body: body,
        files: {
          'banner': bannerImage.value!,
          if (rafflePrizeImage.value != null)
            'rafflePrizeImage': rafflePrizeImage.value!,
        },
      );
      return true;
    } catch (e) {
      message.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _clearCategorySpecificFields() {
    dateController.clear();
    timeController.clear();
    personController.clear();
    maxSupplyController.clear();
    raffleDateController.clear();
    couponTitleController.clear();

    rafflePrizeImage.value = null;
    tasks.clear();
    selectedRouteCondition.value = null;
    eventDate.value = null;
    eventTime.value = null;
    routeOpeningTime.value = null;
    raffleRange.value = null;
  }
}
