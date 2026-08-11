import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/core/utils/acitvity_validator.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/features/event/data/models/event_detail_model.dart';
import 'package:loci/features/explore_activity/data/models/update_event_request_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_event_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/explore_activity_edit_form.dart';
import 'package:loci/features/places/data/models/place_models.dart';

class EventEditController extends GetxController {
  EventEditController(this._service);

  final ExploreActivityService _service;
  BusinessEventDetailsController get _details =>
      Get.find<BusinessEventDetailsController>();

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final personController = TextEditingController();
  final locationController = TextEditingController();
  final mapUrlController = TextEditingController();

  final Rxn<File> bannerImage = Rxn<File>();
  final RxBool isPublic = false.obs;

  /// Coordinates for the current location — seeded from the loaded event and
  /// updated whenever the user picks a new place.
  final Rxn<double> pickedLat = Rxn<double>();
  final Rxn<double> pickedLng = Rxn<double>();

  void setPickedLocation(PickedLocation place) {
    pickedLat.value = place.lat;
    pickedLng.value = place.lng;
    formVersion.value++;
  }

  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> selectedTime = Rxn<TimeOfDay>();
  final RxInt formVersion = 0.obs;

  final RxBool isUpdating = false.obs;
  final RxnString updateError = RxnString();

  late String eventId;
  late String businessId;

  Map<String, dynamic>? _initialData;

  bool get isLoadingDetails => _details.isLoading.value;
  String? get detailsError => _details.errorMessage.value;
  EventDetailsModel? get eventDetails => _details.eventDetails.value;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    eventId = args?['eventId']?.toString() ?? '';
    businessId = args?['businessId']?.toString() ?? '';
    _bindListeners();
  }

  @override
  void onReady() {
    super.onReady();
    loadDetails();
  }

  @override
  void onClose() {
    titleController.dispose();
    detailsController.dispose();
    dateController.dispose();
    timeController.dispose();
    personController.dispose();
    locationController.dispose();
    mapUrlController.dispose();
    super.onClose();
  }

  Future<void> loadDetails() async {
    await _details.fetchEventDetails(
      eventId,
      businessId: businessId.isNotEmpty ? businessId : null,
    );
    final details = _details.eventDetails.value;
    if (details != null) {
      setData(details);
    }
  }

  void setData(EventDetailsModel details) {
    final event = details.eventModel;
    final parsedDate = DateTime.parse(event.date).toLocal();
    selectedDate.value = parsedDate;
    selectedTime.value = parseTime(event.eventTime);

    final friendlyDate = DateParserHelper.toFriendlyDate(parsedDate);
    final friendlyTime = event.eventTime;

    pickedLat.value = details.lat;
    pickedLng.value = details.lng;

    _initialData = {
      'title': event.title,
      'details': event.description,
      'date': friendlyDate,
      'time': friendlyTime,
      'location': event.location,
      'mapUrl': details.mapUrl ?? '',
      'maxParticipants': event.maxAttendees.toString(),
      'isPublic': event.isPublic,
    };

    titleController.text = _initialData!['title'] as String;
    detailsController.text = _initialData!['details'] as String;
    locationController.text = _initialData!['location'] as String;
    mapUrlController.text = _initialData!['mapUrl'] as String;
    personController.text = _initialData!['maxParticipants'] as String;
    dateController.text = _initialData!['date'] as String;
    timeController.text = _initialData!['time'] as String;
    isPublic.value = event.isPublic;

    formVersion.value++;
  }

  bool hasChanged() {
    formVersion.value;
    if (_initialData == null) return false;

    return editFieldChanged(titleController.text, _initialData!['title'] as String) ||
        editFieldChanged(
          detailsController.text,
          _initialData!['details'] as String,
        ) ||
        editFieldChanged(
          locationController.text,
          _initialData!['location'] as String,
        ) ||
        editFieldChanged(mapUrlController.text, _initialData!['mapUrl'] as String) ||
        editFieldChanged(
          personController.text,
          _initialData!['maxParticipants'] as String,
        ) ||
        dateController.text != _initialData!['date'] ||
        timeController.text != _initialData!['time'] ||
        isPublic.value != _initialData!['isPublic'] ||
        bannerImage.value != null;
  }

  void setBanner(File file) {
    bannerImage.value = file;
    formVersion.value++;
  }

  void setPublic(bool value) {
    isPublic.value = value;
    formVersion.value++;
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existing = selectedDate.value;
    // Don't allow scheduling into the past, but keep an already-past event's
    // date reachable so the picker never asserts on initialDate < firstDate.
    final firstDate = (existing != null && existing.isBefore(today))
        ? existing
        : today;
    final initialDate = (existing != null && !existing.isBefore(firstDate))
        ? existing
        : firstDate;

    final pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      initialDate: initialDate,
      lastDate: DateTime(2049),
    );

    if (pickedDate == null) return;
    selectedDate.value = pickedDate;
    dateController.text = DateParserHelper.toFriendlyDate(pickedDate);
    formVersion.value++;
  }

  Future<void> pickTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
    );

    if (pickedTime == null) return;
    selectedTime.value = pickedTime;
    if (!context.mounted) return;
    timeController.text = pickedTime.format(context);
    formVersion.value++;
  }

  Future<void> submit() async {
    final details = _details.eventDetails.value;
    final event = details?.eventModel;
    if (event == null || _initialData == null) return;

    final title = titleController.text.trim();
    final desc = detailsController.text.trim();
    final location = locationController.text.trim();
    final mapUrl = mapUrlController.text.trim();
    final maxParticipants = personController.text.trim();

    final hasBanner =
        bannerImage.value != null || event.coverImage.isNotEmpty;

    if (!ActivityValidator.reportEditValidationFailure(
      ActivityValidator.validateEventEdit(
        formKey: formKey,
        title: title,
        description: desc,
        location: location,
        hasCoordinates: pickedLat.value != null && pickedLng.value != null,
        maxParticipants: maxParticipants,
        eventDate: selectedDate.value,
        eventTime: selectedTime.value,
        hasBanner: hasBanner,
      ),
    )) {
      return;
    }

    if (!ensureHasChanges(hasChanges: hasChanged())) return;

    // PATCH: only send fields the user actually changed. Compare trimmed text
    // against the captured initial snapshot so unchanged values stay out.

    final request = EventUpdateRequest(
      eventId: eventId,
      title: editFieldChanged(title, _initialData!['title'] as String)
          ? title
          : null,
      details: editFieldChanged(desc, _initialData!['details'] as String)
          ? desc
          : null,
      location: editFieldChanged(location, _initialData!['location'] as String)
          ? location
          : null,
      // Send coordinates whenever the location text changed (both or neither).
      lat: editFieldChanged(location, _initialData!['location'] as String)
          ? pickedLat.value
          : null,
      lng: editFieldChanged(location, _initialData!['location'] as String)
          ? pickedLng.value
          : null,
      url: editFieldChanged(mapUrl, _initialData!['mapUrl'] as String)
          ? mapUrl
          : null,
      maxParticipants: editFieldChanged(
        maxParticipants,
        _initialData!['maxParticipants'] as String,
      )
          ? int.tryParse(maxParticipants)
          : null,
      isPublic: isPublic.value != (_initialData!['isPublic'] as bool)
          ? isPublic.value
          : null,
      eventTime: timeController.text != _initialData!['time']
          ? timeController.text
          : null,
      eventDate: dateController.text != _initialData!['date']
          ? selectedDate.value?.toUtc().toIso8601String()
          : null,
      banner: bannerImage.value,
    );

    try {
      isUpdating.value = true;
      updateError.value = null;
      await _service.updateEvent(request);
      isUpdating.value = false;
      Get.back(result: true);
      SnackbarService.success('Event updated successfully');
    } catch (e) {
      isUpdating.value = false;
      final msg = e.toString().replaceFirst('Exception: ', '');
      updateError.value = msg;
      SnackbarService.error(msg);
    }
  }

  void _bindListeners() {
    for (final c in [
      titleController,
      detailsController,
      dateController,
      timeController,
      personController,
      locationController,
      mapUrlController,
    ]) {
      c.addListener(() => formVersion.value++);
    }
  }
}
