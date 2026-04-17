// lib/core/constants/utils/activity_type.dart
// enum ActivityType { Event, Routes, Raffles }



enum ActivityType {
  event,
  routes,
  raffles;

  /// FROM STRING (API → APP)
  static ActivityType fromString(String? value) {
    switch (value) {
      case 'Event':
        return ActivityType.event;
      case 'Routes':
        return ActivityType.routes;
      case 'Raffles':
        return ActivityType.raffles;
      default:
        return ActivityType.event;
    }
  }

  /// UI LABEL
  String get label {
    switch (this) {
      case ActivityType.event:
        return 'Event';
      case ActivityType.routes:
        return 'Routes';
      case ActivityType.raffles:
        return 'Raffles';
    }
  }

  /// TO API
  String get toJson {
    switch (this) {
      case ActivityType.event:
        return 'Event';
      case ActivityType.routes:
        return 'Routes';
      case ActivityType.raffles:
        return 'Raffles';
    }
  }
}