import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/my_business/data/models/submit_ad_request_model.dart';
import 'package:loci/features/my_business/domain/services/my_business_service.dart';

class CreateAdController extends GetxController {
  CreateAdController(this._service);

  final MyBusinessService _service;

  static const int titleMin = 2;
  static const int titleMax = 200;
  static const int businessNameMax = 200;

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final businessController = TextEditingController();
  final locationController = TextEditingController();
  final startDateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endDateController = TextEditingController();
  final endTimeController = TextEditingController();

  final adBanner = Rxn<File>();
  final imageError = RxnString();
  final endDateError = RxnString();

  final startDate = Rxn<DateTime>();
  final startTime = Rxn<TimeOfDay>();
  final endDate = Rxn<DateTime>();
  final endTime = Rxn<TimeOfDay>();

  final businessLocked = false.obs;

  /// The business this ad is for — sent to the backend so it knows which
  /// business's ad credits to spend (required for multi-business owners).
  String? _businessId;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    _hydrateFromArguments(Get.arguments);
  }

  @override
  void onClose() {
    titleController.dispose();
    businessController.dispose();
    locationController.dispose();
    startDateController.dispose();
    startTimeController.dispose();
    endDateController.dispose();
    endTimeController.dispose();
    super.onClose();
  }

  void _hydrateFromArguments(dynamic args) {
    if (args is! Map) return;
    if (args['businessId'] is String) {
      _businessId = args['businessId'] as String;
    }
    if (args['businessName'] is String) {
      final name = args['businessName'] as String;
      businessController.text = name;
      businessLocked.value = name.isNotEmpty;
    }
    if (args['location'] is String) {
      locationController.text = args['location'] as String;
    }
  }

  DateTime initialDateForPicker({required bool isStart}) {
    final initial = isStart
        ? (startDate.value ?? DateTime.now())
        : (endDate.value ?? startDate.value ?? DateTime.now());
    final first = isStart
        ? DateTime.now()
        : (startDate.value ?? DateTime.now());
    return initial.isBefore(first) ? first : initial;
  }

  DateTime firstDateForPicker({required bool isStart}) {
    return isStart ? DateTime.now() : (startDate.value ?? DateTime.now());
  }

  TimeOfDay initialTimeForPicker({required bool isStart}) {
    return isStart
        ? (startTime.value ?? TimeOfDay.now())
        : (endTime.value ?? TimeOfDay.now());
  }

  void applyPickedDate(DateTime picked, {required bool isStart}) {
    if (isStart) {
      startDate.value = picked;
      startDateController.text =
          '${picked.day}/${picked.month}/${picked.year}';
      if (endDate.value != null && endDate.value!.isBefore(picked)) {
        endDate.value = null;
        endDateController.clear();
        endTimeController.clear();
        endTime.value = null;
      }
    } else {
      endDate.value = picked;
      endDateController.text =
          '${picked.day}/${picked.month}/${picked.year}';
      endDateError.value = null;
    }
    formKey.currentState?.validate();
  }

  void applyPickedTime(TimeOfDay picked, BuildContext context,
      {required bool isStart}) {
    if (isStart) {
      startTime.value = picked;
      startTimeController.text = picked.format(context);
    } else {
      endTime.value = picked;
      endTimeController.text = picked.format(context);
    }
    formKey.currentState?.validate();
  }

  void setAdBanner(File? file) {
    adBanner.value = file;
    if (file != null) imageError.value = null;
  }

  String? validateTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Title is required';
    if (v.length < titleMin) {
      return 'Title must be at least $titleMin characters';
    }
    if (v.length > titleMax) {
      return 'Title must be at most $titleMax characters';
    }
    return null;
  }

  String? validateBusinessName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length > businessNameMax) {
      return 'Business name must be at most $businessNameMax characters';
    }
    return null;
  }

  String? validateEndDateField(String? _) =>
      endDate.value == null ? 'Pick an end date' : null;

  String? validateEndTimeField(String? _) =>
      endTime.value == null ? 'Pick an end time' : null;

  DateTime? _combinedStart() => _combine(startDate.value, startTime.value);

  DateTime? _combinedEnd() => _combine(endDate.value, endTime.value);

  DateTime? _combine(DateTime? date, TimeOfDay? time) {
    if (date == null) return null;
    final t = time ?? const TimeOfDay(hour: 0, minute: 0);
    return DateTime(date.year, date.month, date.day, t.hour, t.minute);
  }

  String? _validateSchedule() {
    final start = _combinedStart();
    final end = _combinedEnd();
    if (end == null) return 'End date is required';
    if (start != null && !end.isAfter(start)) {
      return 'End must be after start';
    }
    if (end.isBefore(DateTime.now())) {
      return 'End date must be in the future';
    }
    return null;
  }

  /// Validates the form and submits via [MyBusinessService]. Returns true on success.
  Future<bool> submit() async {
    final scheduleError = _validateSchedule();
    imageError.value =
        adBanner.value == null ? 'Please select an ad banner' : null;
    endDateError.value = scheduleError;

    final formOk = formKey.currentState?.validate() ?? false;
    if (!formOk || adBanner.value == null || scheduleError != null) {
      return false;
    }

    final end = _combinedEnd()!;
    final start = _combinedStart();

    final businessName = businessController.text.trim();
    final location = locationController.text.trim();

    try {
      isLoading.value = true;
      errorMessage.value = null;
      successMessage.value = null;

      successMessage.value = await _service.submitAd(
        SubmitAdRequestModel(
          title: titleController.text.trim(),
          businessId: _businessId,
          businessName: businessName.isEmpty ? null : businessName,
          location: location.isEmpty ? null : location,
          startDate: start,
          endDate: end,
          image: adBanner.value!,
        ),
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
