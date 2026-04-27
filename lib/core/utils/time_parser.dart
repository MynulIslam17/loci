import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Converts a TimeOfDay object to a formatted 12-hour string (e.g. 9:30 AM)
/// Used when user selects time from a picker
String formatTime(TimeOfDay time) {
  int hour = time.hour;
  int minute = time.minute;
  String period = "AM";

  if (hour >= 12) {
    period = "PM";
    if (hour > 12) hour -= 12;
  } else if (hour == 0) {
    hour = 12;
  }

  return "$hour:${minute.toString().padLeft(2, '0')} $period";
}

/// Combines a selected date and time into a UTC ISO string
/// Used when sending data to API (backend expects UTC format)
String combineToUtcIso(DateTime date, TimeOfDay time) {
  final combined = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );

  return combined.toUtc().toIso8601String();
}

/// Parses a time string into TimeOfDay
/// Supports:
/// - 12-hour format (e.g. "9:30 PM")
/// - 24-hour format (e.g. "21:30")
/// Returns null if parsing fails
TimeOfDay? parseTime(String? time) {
  if (time == null || time.trim().isEmpty) return null;

  try {
    time = time.trim().replaceAll(RegExp(r'\s+'), ' ');

    final is12Hour = time.toUpperCase().contains("AM") || time.toUpperCase().contains("PM");

    if (is12Hour) {
      final parts = time.split(' ');
      final timePart = parts[0];
      final period = parts[1].toUpperCase();

      final split = timePart.split(':');
      int hour = int.parse(split[0]);
      int minute = int.parse(split[1]);

      if (period == "PM" && hour != 12) hour += 12;
      if (period == "AM" && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } else {
      // 24-hour format support
      final split = time.split(':');
      int hour = int.parse(split[0]);
      int minute = int.parse(split[1]);

      return TimeOfDay(hour: hour, minute: minute);
    }
  } catch (e) {
    debugPrint("parseTime failed: $time → $e");
    return null;
  }
}

/// Converts UTC ISO string (from API) to local formatted time string
/// Example:
/// Input:  "2026-04-09T03:09:53.240Z"
/// Output: "9:09 AM" (based on device timezone)
/// Used when displaying API time in UI
String formatUtcToLocalTime(String utcString) {
  final dt = DateTime.parse(utcString).toLocal();

  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';

  return "$hour:$minute $ampm";
}