import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../enums/activity_type.dart';
import '../enums/routeType.dart';

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
      return "FORM_INVALID";
    }

    if (bannerPath == null) {
      return "Please select banner image";
    }

    // EVENT
    if (category == ActivityType.event) {
      if (eventDate == null) return "Select event date";
      if (eventTime == null) return "Select event time";
    }

    // ROUTE
    if (category == ActivityType.routes) {
      if (routeOpeningTime == null) return "Select opening time";
      if (routeType == null) return "Select route type";
    }

    // RAFFLE
    if (category == ActivityType.raffles) {
      if (raffleRange == null) {
        return "Select raffle date range";
      }

      if (!hasCoupon) return "Upload voucher";
      if (!hasTasks) return "Add tasks";
    }

    return null;
  }
}