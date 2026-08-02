import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/routeType.dart';
import 'package:loci/core/utils/acitvity_validator.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/features/explore_activity/data/models/update_route_request_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';
import 'package:loci/features/explore_activity/presentation/controllers/business_route_details_controller.dart';
import 'package:loci/features/explore_activity/presentation/controllers/explore_activity_edit_form.dart';
import 'package:loci/features/routes/data/models/route_detail_model.dart';
import 'package:loci/features/routes/data/models/route_list_model.dart';
import 'package:loci/features/places/data/models/place_models.dart';

class RouteEditController extends GetxController {
  RouteEditController(this._service);

  final ExploreActivityService _service;
  BusinessRouteDetailsController get _details =>
      Get.find<BusinessRouteDetailsController>();

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();
  final mapUrlController = TextEditingController();

  final Rxn<TimeOfDay> selectedTime = Rxn<TimeOfDay>();
  final Rxn<RouteType> availabilityType = Rxn<RouteType>();
  final RxBool isPublic = true.obs;
  final Rxn<File> bannerImage = Rxn<File>();
  final RxInt formVersion = 0.obs;

  /// Coordinates for the current location — seeded from the loaded route and
  /// updated whenever the user picks a new place.
  final Rxn<double> pickedLat = Rxn<double>();
  final Rxn<double> pickedLng = Rxn<double>();

  void setPickedLocation(PickedLocation place) {
    pickedLat.value = place.lat;
    pickedLng.value = place.lng;
    formVersion.value++;
  }

  final RxBool isUpdating = false.obs;
  final RxnString updateError = RxnString();

  late String routeId;
  late String businessId;

  Map<String, dynamic>? _initialData;

  bool get isLoadingDetails => _details.isLoading.value;
  String? get detailsError => _details.errorMessage.value;
  RouteModel? get route => _details.routeDetails.value?.routeModel;
  RouteDetails? get routeDetails => _details.routeDetails.value;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    routeId = args?['routeId']?.toString() ?? '';
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
    timeController.dispose();
    locationController.dispose();
    mapUrlController.dispose();
    super.onClose();
  }

  Future<void> loadDetails() async {
    await _details.fetchRouteDetails(
      routeId,
      businessId: businessId.isNotEmpty ? businessId : null,
    );
    final details = _details.routeDetails.value;
    if (details?.routeModel != null) {
      setData(details!);
    }
  }

  void setData(RouteDetails routeDetails) {
    final route = routeDetails.routeModel;
    final parsedTime = parseTime(route.openingTime);

    pickedLat.value = routeDetails.coordinates.lat;
    pickedLng.value = routeDetails.coordinates.lng;

    _initialData = {
      'title': route.title,
      'details': route.details,
      'location': route.location,
      'mapUrl': routeDetails.mapUrl ?? '',
      'isPublic': route.isRoutePublic,
      'availabilityType': RouteType.fromString(route.availabilityType),
      'time': parsedTime != null ? formatTime(parsedTime) : '',
    };

    titleController.text = _initialData!['title'] as String;
    detailsController.text = _initialData!['details'] as String;
    locationController.text = _initialData!['location'] as String;
    mapUrlController.text = _initialData!['mapUrl'] as String;
    isPublic.value = _initialData!['isPublic'] as bool;
    availabilityType.value = _initialData!['availabilityType'] as RouteType?;
    selectedTime.value = parsedTime;
    timeController.text = _initialData!['time'] as String;

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
        isPublic.value != _initialData!['isPublic'] ||
        availabilityType.value != _initialData!['availabilityType'] ||
        timeController.text != _initialData!['time'] ||
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

  void setAvailabilityType(RouteType? value) {
    availabilityType.value = value;
    formVersion.value++;
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );

    if (picked == null) return;

    selectedTime.value = picked;
    timeController.text = formatTime(picked);
    formVersion.value++;
  }

  Future<void> submit() async {
    final routeDetails = _details.routeDetails.value;
    final route = routeDetails?.routeModel;
    if (route == null || _initialData == null) return;

    final title = titleController.text.trim();
    final desc = detailsController.text.trim();
    final location = locationController.text.trim();
    final mapUrl = mapUrlController.text.trim();

    final hasBanner = bannerImage.value != null || route.banner.isNotEmpty;

    if (!ActivityValidator.reportEditValidationFailure(
      ActivityValidator.validateRouteEdit(
        formKey: formKey,
        title: title,
        description: desc,
        location: location,
        hasCoordinates: pickedLat.value != null && pickedLng.value != null,
        openingTime: selectedTime.value,
        routeType: availabilityType.value,
        hasBanner: hasBanner,
      ),
    )) {
      return;
    }

    if (!ensureHasChanges(hasChanges: hasChanged())) return;

    // PATCH: only send changed fields, comparing trimmed input to the snapshot.

    final request = RouteUpdateRequest(
      routeId: routeId,
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
      isPublic: isPublic.value != (_initialData!['isPublic'] as bool)
          ? isPublic.value
          : null,
      availabilityType:
          availabilityType.value?.apiValue != route.availabilityType
          ? availabilityType.value
          : null,
      openingTime: timeController.text != _initialData!['time']
          ? timeController.text
          : null,
      bannerFile: bannerImage.value,
    );

    try {
      isUpdating.value = true;
      updateError.value = null;
      await _service.updateRoute(request);
      isUpdating.value = false;
      Get.back(result: true);
      SnackbarService.success('Route updated successfully');
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
      locationController,
      mapUrlController,
      timeController,
    ]) {
      c.addListener(() => formVersion.value++);
    }
  }
}
