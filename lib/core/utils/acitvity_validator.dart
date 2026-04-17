import 'package:flutter/material.dart';
import 'package:loci/core/enums/activity_type.dart';
import '../enums/routeType.dart';

class ActivityValidator {
  static String? validateAll({
    required GlobalKey<FormState> formKey,
    required String? bannerPath,
    required ActivityType category,

    DateTime? date,
    TimeOfDay? time,
    RouteType? routeType,
    bool hasCoupon = false,
    bool hasTasks = false,
  }) {
    // 1. Form fields validation
    if (!formKey.currentState!.validate()) {
      return "FORM_INVALID";
    }

    // 2. Banner
    if (bannerPath == null) {
      return "Please select banner image";
    }

    // 3. Event
    if (category == ActivityType.event) {
      if (date == null) return "Select event date";
      if (time == null) return "Select event time";
    }

    // 4. Route
    if (category == ActivityType.routes) {
      if (time == null) return "Select opening time";
      if (routeType == null) return "Select route type";
    }

    // 5. Raffle
    if (category == ActivityType.raffles) {
      if (date == null) return "Select due date";
      if (!hasCoupon) return "Upload voucher";
      if (!hasTasks) return "Add tasks";
    }

    return null; // no error
  }
}