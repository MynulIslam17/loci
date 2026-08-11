import 'package:flutter/material.dart';

import '../enums/activity_type.dart';
import '../enums/routeType.dart';
import 'show_snackbar.dart';

class ActivityValidator {
  static String? validateAll({
    required GlobalKey<FormState> formKey,
    required String? bannerPath,
    required ActivityType category,

    // EVENT
    DateTime? eventDate,
    TimeOfDay? eventTime,

    // ROUTE
    TimeOfDay? routeOpeningTime,
    RouteType? routeType,

    // RAFFLE
    DateTimeRange? raffleRange,

    bool hasCoupon = false,
    bool hasTasks = false,
  }) {
    if (!formKey.currentState!.validate()) {
      return 'FORM_INVALID';
    }

    if (bannerPath == null) {
      return 'Please select banner image';
    }

    // EVENT
    if (category == ActivityType.event) {
      if (eventDate == null) return 'Select event date';
      if (eventTime == null) return 'Select event time';
    }

    // ROUTE
    if (category == ActivityType.routes) {
      if (routeOpeningTime == null) return 'Select opening time';
      if (routeType == null) return 'Select route type';
    }

    // RAFFLE
    if (category == ActivityType.raffles) {
      if (raffleRange == null) {
        return 'Select raffle date range';
      }

      if (!hasCoupon) return 'Upload voucher';
      if (!hasTasks) return 'Add tasks';
    }

    return null;
  }

  /// Shows a snackbar when validation fails; returns true if submit may continue.
  static bool reportEditValidationFailure(String? error) {
    if (error == null) return true;
    if (error == 'FORM_INVALID') {
      SnackbarService.error('Please fix the highlighted fields');
    } else {
      SnackbarService.error(error);
    }
    return false;
  }

  static String? _validateTitle(String title) {
    final text = title.trim();
    if (text.isEmpty) return 'Title is required';
    if (text.length < 3) return 'Title should be at least 3 characters';
    if (text.length > 100) return 'Title must be under 100 characters';
    return null;
  }

  static String? _validateDescription(String description, {required int maxLength}) {
    final text = description.trim();
    if (text.isEmpty) return 'Description is required';
    if (text.length > maxLength) {
      return 'Description must be under $maxLength characters';
    }
    return null;
  }

  static String? _validateLocation(String location) {
    final text = location.trim();
    if (text.isEmpty) return 'Location is required';
    if (text.length < 3) return 'Enter a more specific location';
    return null;
  }

  /// Optional website (the repurposed `url` field). Empty is allowed; if
  /// present it must be a real http(s) link.
  static String? validateOptionalWebsite(String? url) {
    final text = url?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final isValid = uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;
    if (!isValid) return 'Enter a valid link starting with https://';
    return null;
  }

  static String? _validateMaxParticipants(String value) {
    final text = value.trim();
    if (text.isEmpty) return 'Max participants is required';
    final count = int.tryParse(text);
    if (count == null) return 'Enter a valid number';
    if (count < 1) return 'Must allow at least 1 participant';
    return null;
  }

  static String? _validateMaxSupply(String value) {
    final text = value.trim();
    if (text.isEmpty) return 'Max supply is required';
    final supply = int.tryParse(text);
    if (supply == null) return 'Enter a valid number';
    if (supply < 1) return 'Supply must be at least 1';
    return null;
  }

  static String? _validatePrizeName(String name) {
    if (name.trim().isEmpty) return 'Prize name is required';
    return null;
  }

  static String? _runEditFormValidation(GlobalKey<FormState> formKey) {
    final formState = formKey.currentState;
    if (formState == null) return 'FORM_INVALID';
    if (!formState.validate()) return 'FORM_INVALID';
    return null;
  }

  /// Same required rules as create — edit must keep title, schedule, media, etc.
  static String? validateEventEdit({
    required GlobalKey<FormState> formKey,
    required String title,
    required String description,
    required String location,
    required bool hasCoordinates,
    required String maxParticipants,
    required DateTime? eventDate,
    required TimeOfDay? eventTime,
    required bool hasBanner,
    int descriptionMaxLength = 200,
  }) {
    final formError = _runEditFormValidation(formKey);
    if (formError != null) return formError;

    for (final check in [
      _validateTitle(title),
      _validateDescription(description, maxLength: descriptionMaxLength),
      _validateLocation(location),
      _validateMaxParticipants(maxParticipants),
    ]) {
      if (check != null) return check;
    }

    if (!hasCoordinates) return 'Please pick a location from search';
    if (!hasBanner) return 'Banner image is required';
    if (eventDate == null) return 'Select event date';
    if (eventTime == null) return 'Select event time';
    return null;
  }

  static String? validateRouteEdit({
    required GlobalKey<FormState> formKey,
    required String title,
    required String description,
    required String location,
    required bool hasCoordinates,
    required TimeOfDay? openingTime,
    required RouteType? routeType,
    required bool hasBanner,
    int descriptionMaxLength = 200,
  }) {
    final formError = _runEditFormValidation(formKey);
    if (formError != null) return formError;

    for (final check in [
      _validateTitle(title),
      _validateDescription(description, maxLength: descriptionMaxLength),
      _validateLocation(location),
    ]) {
      if (check != null) return check;
    }

    if (!hasCoordinates) return 'Please pick a location from search';
    if (!hasBanner) return 'Banner image is required';
    if (openingTime == null) return 'Select opening time';
    if (routeType == null) return 'Select route type';
    return null;
  }

  static String? validateRaffleEdit({
    required GlobalKey<FormState> formKey,
    required String title,
    required String description,
    required String maxSupply,
    required String prizeName,
    required DateTime? startDate,
    required DateTime? endDate,
    required bool hasBanner,
    required bool hasCoupon,
    required bool hasTasks,
    int descriptionMaxLength = 200,
  }) {
    final formError = _runEditFormValidation(formKey);
    if (formError != null) return formError;

    for (final check in [
      _validateTitle(title),
      _validateDescription(description, maxLength: descriptionMaxLength),
      _validateMaxSupply(maxSupply),
      _validatePrizeName(prizeName),
    ]) {
      if (check != null) return check;
    }

    if (!hasBanner) return 'Banner image is required';
    if (startDate == null || endDate == null) {
      return 'Select raffle date range';
    }
    if (!hasCoupon) return 'Coupon image is required';
    if (!hasTasks) return 'At least one task is required';
    return null;
  }
}
